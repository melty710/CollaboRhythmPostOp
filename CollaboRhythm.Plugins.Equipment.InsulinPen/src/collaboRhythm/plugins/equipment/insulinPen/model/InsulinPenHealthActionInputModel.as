package collaboRhythm.plugins.equipment.insulinPen.model
{
	import collaboRhythm.plugins.schedule.shared.model.HealthActionInputModelBase;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionModelDetailsProvider;
	import collaboRhythm.shared.model.healthRecord.DocumentBase;
	import collaboRhythm.shared.model.healthRecord.document.MedicationAdministration;
	import collaboRhythm.shared.model.healthRecord.document.MedicationOrder;
	import collaboRhythm.shared.model.healthRecord.document.MedicationScheduleItem;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;
	import collaboRhythm.shared.model.services.ICurrentDateSource;
	import collaboRhythm.shared.model.services.WorkstationKernel;

	import flash.net.URLVariables;

	public class InsulinPenHealthActionInputModel extends HealthActionInputModelBase
	{
		private var _medicationScheduleItem:MedicationScheduleItem;
		private var _medicationOrder:MedicationOrder;

		public function InsulinPenHealthActionInputModel(scheduleItemOccurrence:ScheduleItemOccurrence = null,
														 healthActionModelDetailsProvider:IHealthActionModelDetailsProvider = null)
		{
			super(scheduleItemOccurrence, healthActionModelDetailsProvider);

			_medicationScheduleItem = scheduleItemOccurrence.scheduleItem as MedicationScheduleItem;
			_medicationOrder = _medicationScheduleItem.scheduledMedicationOrder;

			_currentDateSource = WorkstationKernel.instance.resolve(ICurrentDateSource) as ICurrentDateSource;
		}


		override public function set urlVariables(value:URLVariables):void
		{
			var medicationAdministration:MedicationAdministration = new MedicationAdministration();
			medicationAdministration.init(_medicationOrder.name, _healthActionModelDetailsProvider.accountId,
					_currentDateSource.now(), _currentDateSource.now(),
					_medicationScheduleItem.dose);

			var adherenceResults:Vector.<DocumentBase> = new Vector.<DocumentBase>();
			adherenceResults.push(medicationAdministration);
			scheduleItemOccurrence.createAdherenceItem(adherenceResults, _healthActionModelDetailsProvider.record,
					_healthActionModelDetailsProvider.accountId);

			_urlVariables = value;
		}
	}
}
