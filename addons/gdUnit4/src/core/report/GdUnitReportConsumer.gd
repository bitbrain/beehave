# Report consumer interace to collect reports 
class_name GdUnitReportConsumer
extends RefCounted

const META_PARAM :StringName = "gdunitReportConsumer"

# must be implemented to collect reports
func consume(report :GdUnitReport) -> void:
	pass

# register a report provider to enable consuming reports
func register_report_provider(provider :Object):
	provider.set_meta(META_PARAM, self)
