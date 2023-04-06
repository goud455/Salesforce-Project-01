trigger ContentVersionExternalLink on ContentVersion (after insert) {
    system.debug('@@@ContentVersionTrigger called');
	ContentTriggerHandler.createPublicLinkForFile(trigger.new);
}