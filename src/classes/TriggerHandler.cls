global class TriggerHandler
{

    public static Boolean isScheduled = false;
    public static Boolean isEnabled = true;

    global enum Events {
        AFTER_DELETE, AFTER_INSERT, AFTER_UNDELETE, AFTER_UPDATE,
        BEFORE_DELETE, BEFORE_INSERT, BEFORE_UPDATE
    }

    global interface HandlerInterface {

        List<Filter__c> getFilters();

        void handle();
    }

    Map<String, List<HandlerInterface>> eventHandlerMapping = new Map<String, List<HandlerInterface>>();

    global TriggerHandler bind(Events event, HandlerInterface eh) {
        List<HandlerInterface> handlers = eventHandlerMapping.get(event.name());
        if (handlers == null)
        {
            handlers = new List<HandlerInterface>();
            eventHandlerMapping.put(event.name(), handlers);
        }
        handlers.add(eh);
        return this;
    }

    global void manage() {
        Events ev = null;
        List<HandlerInterface> handlers;

        try {
            if (Trigger.isInsert && Trigger.isAfter) {
                ev = Events.AFTER_INSERT;
            }
            else if (Trigger.isUpdate && Trigger.isAfter) {
                ev = Events.AFTER_UPDATE;
            }

            handlers = eventHandlerMapping.get(ev.name());
        }
        catch (Exception exc) {
            handlers = eventHandlerMapping.values().get(0);
        }

        /**
         * On other triggers needed.
         */
         /*
        if (Trigger.isInsert && Trigger.isBefore) {
            ev = Events.BEFORE_INSERT;
        }
        else if (Trigger.isUpdate && Trigger.isBefore) {
            ev = Events.BEFORE_UPDATE;
        }
        else if (Trigger.isDelete && Trigger.isBefore) {
            ev = Events.BEFORE_DELETE;
        }
        else if (Trigger.isDelete && Trigger.isAfter) {
            ev = Events.AFTER_DELETE;
        }
        else if (Trigger.isundelete) {
            ev = Events.AFTER_UNDELETE;
        }*/

        if (handlers != null && ! handlers.isEmpty() && isEnabled) {
            for (HandlerInterface h : handlers) {
                if (h.getFilters() != null && !h.getFilters().isEmpty()) {
                    h.handle();
                }
            }
        }
    }

}