import 'dart:math' as math;
import 'dart:typed_data';

const metronomeSampleRate = 44100;

/// Tiny mono 16-bit PCM WAV click (Spec 0030).
Uint8List synthesizeClickWav({
  required double frequencyHz,
  required int durationMs,
  required double amplitude,
  int sampleRate = metronomeSampleRate,
}) {
  final sampleCount = (sampleRate * durationMs / 1000).round().clamp(
    1,
    sampleRate,
  );
  final pcm = _synthesizeClickPcm(
    frequencyHz: frequencyHz,
    sampleCount: sampleCount,
    amplitude: amplitude,
    sampleRate: sampleRate,
  );
  return _wrapWav(pcm: pcm, sampleRate: sampleRate);
}

/// Samples between click onsets in the generated loop.
int metronomeSamplesPerBeat({
  required int tempoBpm,
  int sampleRate = metronomeSampleRate,
}) {
  final bpm = tempoBpm.clamp(1, 400);
  final microsPerBeat = (60000000 / bpm).round();
  return ((sampleRate * microsPerBeat) / 1000000).round().clamp(
    1,
    sampleRate * 10,
  );
}

/// The beat length of the buffer that actually plays, which is the nominal
/// tempo interval rounded to a whole number of samples.
///
/// The beat clock reads this rather than [MetronomePrefs.beatInterval]: the
/// difference is under 10 µs per beat, but a play head that accumulates across
/// loop repeats would turn that into visible drift over a long practice.
Duration metronomeAudioBeatInterval({
  required int tempoBpm,
  int sampleRate = metronomeSampleRate,
}) {
  final samples = metronomeSamplesPerBeat(
    tempoBpm: tempoBpm,
    sampleRate: sampleRate,
  );
  return Duration(microseconds: (samples * 1000000 / sampleRate).round());
}

/// One-bar loop with clicks at exact sample offsets.
///
/// Audioplayers seek/resume per beat jitters on iOS; looping a pre-timed
/// buffer keeps audible intervals sample-accurate.
///
/// The loop spans the whole bar even with the accent off, where every click is
/// identical and one beat would sound the same. That keeps the play head a
/// position *within the bar* for every meter, so the beat clock has one mapping
/// to maintain instead of one per mode.
Uint8List synthesizeMetronomeLoopWav({
  required int tempoBpm,
  required int beatsPerBar,
  required bool accentEnabled,
  int sampleRate = metronomeSampleRate,
}) {
  final beats = beatsPerBar.clamp(1, 24);
  final samplesPerBeat = metronomeSamplesPerBeat(
    tempoBpm: tempoBpm,
    sampleRate: sampleRate,
  );
  final totalSamples = samplesPerBeat * beats;
  final pcm = Float64List(totalSamples); // accumulate then quantize

  void stamp({
    required int atSample,
    required double frequencyHz,
    required int durationMs,
    required double amplitude,
  }) {
    final click = _synthesizeClickPcm(
      frequencyHz: frequencyHz,
      sampleCount: (sampleRate * durationMs / 1000).round().clamp(
        1,
        sampleRate,
      ),
      amplitude: amplitude,
      sampleRate: sampleRate,
    );
    final start = atSample.clamp(0, totalSamples - 1);
    for (var i = 0; i < click.length ~/ 2; i++) {
      final idx = start + i;
      if (idx >= totalSamples) break;
      final s = ByteData.sublistView(click).getInt16(i * 2, Endian.little);
      pcm[idx] += s / 32767.0;
    }
  }

  for (var beat = 0; beat < beats; beat++) {
    final accent = accentEnabled && beat == 0;
    // Same peak level — accent is pitch only so perceived gaps stay even.
    stamp(
      atSample: beat * samplesPerBeat,
      frequencyHz: accent ? 880 : 1200,
      durationMs: accent ? 48 : 38,
      amplitude: 1.0,
    );
  }

  final out = ByteData(totalSamples * 2);
  for (var i = 0; i < totalSamples; i++) {
    final sample = (pcm[i].clamp(-1.0, 1.0) * 32767).round().clamp(
      -32768,
      32767,
    );
    out.setInt16(i * 2, sample, Endian.little);
  }
  return _wrapWav(pcm: out.buffer.asUint8List(), sampleRate: sampleRate);
}

Uint8List _synthesizeClickPcm({
  required double frequencyHz,
  required int sampleCount,
  required double amplitude,
  required int sampleRate,
}) {
  final data = ByteData(sampleCount * 2);
  // Louder than the original 0.35, but keep a pure sine (no harsh overtones).
  final amp = amplitude.clamp(0.0, 1.0) * 0.72;
  final attackSamples = math.min(48, sampleCount ~/ 8);
  for (var i = 0; i < sampleCount; i++) {
    final t = i / sampleRate;
    // Soft attack + exponential decay ≈ classic electronic metronome ping.
    final attack = i < attackSamples ? i / attackSamples : 1.0;
    final decay = math.exp(-3.2 * i / sampleCount);
    final envelope = attack * decay;
    final tone = math.sin(2 * math.pi * frequencyHz * t);
    final sample = (amp * envelope * tone * 32767).round().clamp(-32768, 32767);
    data.setInt16(i * 2, sample, Endian.little);
  }
  return data.buffer.asUint8List();
}

Uint8List _wrapWav({required Uint8List pcm, required int sampleRate}) {
  final dataSize = pcm.length;
  final bytes = ByteData(44 + dataSize);
  void ascii(int offset, String s) {
    for (var i = 0; i < s.length; i++) {
      bytes.setUint8(offset + i, s.codeUnitAt(i));
    }
  }

  ascii(0, 'RIFF');
  bytes.setUint32(4, 36 + dataSize, Endian.little);
  ascii(8, 'WAVE');
  ascii(12, 'fmt ');
  bytes.setUint32(16, 16, Endian.little);
  bytes.setUint16(20, 1, Endian.little);
  bytes.setUint16(22, 1, Endian.little);
  bytes.setUint32(24, sampleRate, Endian.little);
  bytes.setUint32(28, sampleRate * 2, Endian.little);
  bytes.setUint16(32, 2, Endian.little);
  bytes.setUint16(34, 16, Endian.little);
  ascii(36, 'data');
  bytes.setUint32(40, dataSize, Endian.little);
  final out = bytes.buffer.asUint8List();
  out.setRange(44, 44 + dataSize, pcm);
  return out;
}
