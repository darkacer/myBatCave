public virtual class triggerHandler {
    public class TriggerHandlerException extends Exception {
    }

    public triggerHandler() {
        this.setTriggerContext();
    }

    @testVisible
    private TriggerContext context;

    @testVisible
    private Boolean isTriggerExecuting;

    public void run() {
        switch on context {
            when BEFORE_INSERT {
                this.beforeInsert();
            }
            when BEFORE_UPDATE {
                this.beforeUpdate();
            }
            when AFTER_INSERT {
                this.afterInsert();
            }
            when AFTER_UPDATE {
                this.afterUpdate();
            }
            when BEFORE_DELETE {
                this.beforeDelete();
            }
            when AFTER_DELETE {
                this.afterDelete();
            }
            when AFTER_UNDELETE {
                this.afterUndelete();
            }
        }
    }

    /**
     * @description internal method to forcibly set the trigger context
     */
    @testVisible
    private void setTriggerContext() {
        this.setTriggerContext(null, false);
    }

    /**
     * @description    Internal method for manually setting the trigger context
     * @param ctx      The current trigger Context
     * @param testMode Is the trigger running in a test context?
     */
    @testVisible
    private void setTriggerContext(String ctx, Boolean testMode) {
        if (!Trigger.isExecuting && !testMode) {
            this.isTriggerExecuting = false;
            return;
        } else {
            this.isTriggerExecuting = true;
        }

        if (Trigger.isExecuting && !testMode) {
            switch on Trigger.operationType {
                when BEFORE_INSERT {
                    context = TriggerContext.BEFORE_INSERT;
                }
                when BEFORE_UPDATE {
                    context = TriggerContext.BEFORE_UPDATE;
                }
                when BEFORE_DELETE {
                    context = TriggerContext.BEFORE_DELETE;
                }
                when AFTER_INSERT {
                    context = TriggerContext.AFTER_INSERT;
                }
                when AFTER_UPDATE {
                    context = TriggerContext.AFTER_UPDATE;
                }
                when AFTER_DELETE {
                    context = TriggerContext.AFTER_DELETE;
                }
                when AFTER_UNDELETE {
                    context = TriggerContext.AFTER_UNDELETE;
                }
            }
        } else if (ctx != null && testMode) {
            switch on ctx {
                when 'before insert' {
                    context = TriggerContext.BEFORE_INSERT;
                }
                when 'before update' {
                    context = TriggerContext.BEFORE_UPDATE;
                }
                when 'before delete' {
                    context = TriggerContext.BEFORE_DELETE;
                }
                when 'after insert' {
                    context = TriggerContext.AFTER_INSERT;
                }
                when 'after update' {
                    context = TriggerContext.AFTER_UPDATE;
                }
                when 'after delete' {
                    context = TriggerContext.AFTER_DELETE;
                }
                when 'after undelete' {
                    context = TriggerContext.AFTER_UNDELETE;
                }
                when else {
                    throw new TriggerHandler.TriggerHandlerException(
                        'Unexpected trigger context set'
                    );
                }
            }
        }
    }



    /***************************************
     * context methods
     ***************************************/

    /**
     * These methods are all intended to be overridden by
     * individual trigger handlers. They exist here only to
     * establish the 'software contract' that they exist.
     */

    /**
     * @description Virtual method for the implementing class to override
     */
    @testVisible
    @SuppressWarnings('PMD.EmptyStatementBlock')
    protected virtual void beforeInsert() {
    }
    /**
     * @description Virtual method for the implementing class to override
     */
    @testVisible
    @SuppressWarnings('PMD.EmptyStatementBlock')
    protected virtual void beforeUpdate() {
    }
    /**
     * @description Virtual method for the implementing class to override
     */
    @testVisible
    @SuppressWarnings('PMD.EmptyStatementBlock')
    protected virtual void beforeDelete() {
    }
    /**
     * @description Virtual method for the implementing class to override
     */
    @testVisible
    @SuppressWarnings('PMD.EmptyStatementBlock')
    protected virtual void afterInsert() {
    }
    /**
     * @description Virtual method for the implementing class to override
     */
    @testVisible
    @SuppressWarnings('PMD.EmptyStatementBlock')
    protected virtual void afterUpdate() {
    }
    /**
     * @description Virtual method for the implementing class to override
     */
    @testVisible
    @SuppressWarnings('PMD.EmptyStatementBlock')
    protected virtual void afterDelete() {
    }
    /**
     * @description Virtual method for the implementing class to override
     */
    @testVisible
    @SuppressWarnings('PMD.EmptyStatementBlock')
    protected virtual void afterUndelete() {
    }



    /**
     * @description possible trigger contexts
     */
    @testVisible
    private enum TriggerContext {
        BEFORE_INSERT,
        BEFORE_UPDATE,
        BEFORE_DELETE,
        AFTER_INSERT,
        AFTER_UPDATE,
        AFTER_DELETE,
        AFTER_UNDELETE
    }
}