global class GreenmileAPIHelper {
	global virtual interface JSONable {
        String toJSON();
    }
    
    global virtual interface Condition extends JSONable{}
    
    global interface NestableCondition extends Condition{
        NestableCondition add(Condition c);
    }
    
    global abstract class ConditionGroup implements NestableCondition{

        global List<Condition> conditions {get;private set;}

        private String groupOperator {get;set;}

        public ConditionGroup(String groupOperator){
            this.groupOperator = groupOperator;
            this.conditions = new List<Condition>();
        }

        global NestableCondition add(Condition c){
            if(c != null){
                this.conditions.add(c);
            }
            return this;
        }

        global String toJSON(){ 
            List<String> cons = new List<String>();
            for (Condition con: conditions){
                cons.add(con.toJSON());
            }
            
            return '{ "'+groupOperator+'": ['+String.join(cons,',')+' ] }';
        }
    }
    
    global class AndCondition extends ConditionGroup{

        global AndCondition(){
            super('and');
        }

    }

    global class OrCondition extends ConditionGroup{

        global OrCondition(){
            super('or');
        }

    }

//In condition, new change afte rthe greenmile upgrade    
        global class InCondition extends ConditionGroup{

        global InCondition(){
            super('in');
        }

    }
    
    global class AttrCondition implements Condition{

        @AuraEnabled
        global String   attr       { get; private set; }
        @AuraEnabled
        global Operator operation    { get; private set; }
        @AuraEnabled
        global Object   value       { get; private set; }

        global AttrCondition(String attr, Object value){
            this(attr, Operator.EQUALS, value);
        }

        global AttrCondition(String attr, Operator operator, Object value){
            this.attr=attr;
            if(operator!= null){
                this.setOperation(operator,value);
            }
        }

        global AttrCondition eq(Object value){ return setOperation(Operator.EQUALS,value); }
        global AttrCondition gte(Object value){ return setOperation(Operator.GREATER_THAN_OR_EQUAL_TO,value); }
        global AttrCondition lte(Object value){ return setOperation(Operator.LESS_THAN_OR_EQUAL_TO,value); }
        global AttrCondition inx(Object value){ return setOperation(Operator.INX,value); }

        /*
        	global AttrCondition notEq(Object value){ return setOperation(NOT_EQUALS              ,value); }
       		global AttrCondition lt(Object value){ return setOperation(LESS_THAN               ,value); }
        	global AttrCondition ltEq(Object value){ return setOperation(LESS_THAN_OR_EQUAL_TO   ,value); }
        	global AttrCondition gt(Object value){ return setOperation(GREATER_THAN            ,value); }
        */
        private AttrCondition setOperation(Operator operator, Object value){
            //system.debug(operator);
            //system.debug(value);
            this.operation = operator;
            this.value = value;
            return this;
        }

        global String toJSON(){
            
            

            return '{ "attr": "'+Attr+'", "'+operatorToString(operation)+'": "'+value+'" }';  
            
        }
    }
    
    global enum Operator {

        //===============================
        // FIELD OPERATORS
        //===============================
        EQUALS,                // =
        GREATER_THAN_OR_EQUAL_TO,
        LESS_THAN_OR_EQUAL_TO,
            INX // 
        
    }
    
    global static String operatorToString(Operator op){
        String returnValue = null;
        if(     op == Operator.EQUALS)                   { returnValue = 'eq'; }
        if(     op == Operator.GREATER_THAN_OR_EQUAL_TO)                   { returnValue = 'gte'; }
        if(     op == Operator.LESS_THAN_OR_EQUAL_TO)                   { returnValue = 'lte'; }
        if(     op == Operator.INX)                   { returnValue = 'IN'; }
        /*
         * else if(op == NOT_EQUALS)               { returnValue = '!='; }
         * else if(op == LESS_THAN)                { returnValue = '<'; }
         * else if(op == LESS_THAN_OR_EQUAL_TO)    { returnValue = '<='; }
        else if(op == GREATER_THAN)             { returnValue = '>'; }
        else if(op == GREATER_THAN_OR_EQUAL_TO) { returnValue = '>='; }
        else if(op == LIKEX)                    { returnValue = 'like'; }
        else if(op == INX)                    	{ returnValue = 'IN'; }
        else if(op == NOT_IN)                   { returnValue = 'NOT IN'; }
        else if(op == INCLUDES)                 { returnValue = 'INCLUDES'; }
        else if(op == EXCLUDES)                 { returnValue = 'EXCLUDES'; }
		*/

        return returnValue;
    }
}