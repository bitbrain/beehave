## Statistical helpers to summarize benchmark sample arrays.
extends RefCounted


static func summarize(samples: Array[float]) -> Dictionary:
	var sorted := samples.duplicate()
	sorted.sort()
	var mean := 0.0
	for value in sorted:
		mean += value
	mean /= sorted.size()
	var variance := 0.0
	for value in sorted:
		variance += (value - mean) * (value - mean)
	variance /= sorted.size()
	var std_dev := sqrt(variance)
	return {
		samples = sorted.size(),
		mean = mean,
		median = percentile(sorted, 0.5),
		p95 = percentile(sorted, 0.95),
		p99 = percentile(sorted, 0.99),
		min = sorted[0],
		max = sorted[-1],
		std_dev = std_dev,
		cov = std_dev / mean if mean > 0.0 else 0.0,
	}


static func percentile(sorted: Array[float], fraction: float) -> float:
	var position := fraction * (sorted.size() - 1)
	var lower := int(floor(position))
	var upper := int(ceil(position))
	return lerpf(sorted[lower], sorted[upper], position - lower)
