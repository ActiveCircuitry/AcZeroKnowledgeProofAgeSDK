# Performance Benchmarks

Benchmarking suite for Active Circuitry ZKP Age SDK.

## Running Benchmarks

```bash
# Run all benchmarks
dart test/benchmarks/all_benchmarks.dart

# Run specific benchmark
dart test/benchmarks/proof_generation_benchmark.dart
```

## Benchmark Categories

### 1. Proof Generation Performance
- Groth16 vs PLONK generation times
- Hardware security vs software-only
- Impact of different age thresholds

### 2. Verification Performance
- Verification time by protocol
- Batch verification efficiency
- Cache impact on repeated verifications

### 3. Key Management Performance
- Key download speeds
- Key import/export times
- Storage overhead

### 4. Memory Usage
- Peak memory during proof generation
- Memory footprint of stored keys
- Memory efficiency of batch operations

## Results Format

Results are exported in JSON format:

```json
{
  "device": "Pixel 7",
  "android_version": "14",
  "timestamp": "2026-01-11T10:00:00Z",
  "benchmarks": [
    {
      "name": "groth16_generation_18+",
      "mean_ms": 4532,
      "std_dev_ms": 234,
      "samples": 100
    }
  ]
}
```

## Contributing Results

To contribute benchmark results:

1. Run benchmarks on your device
2. Export results using `--export` flag
3. Submit PR with results in `benchmarks/results/`

---

**Copyright © 2026 Active Circuitry Private Ltd.**
