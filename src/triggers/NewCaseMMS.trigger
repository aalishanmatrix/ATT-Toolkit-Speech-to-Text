trigger NewCaseMMS on Case (after insert) {
	SendNewCaseMMS.sendMMSNotification(Trigger.newMap.keySet());
}