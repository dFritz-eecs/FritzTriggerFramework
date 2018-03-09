public abstract class ftf_QuerySelector implements ftf_IQuerySelector{
    private Schema.DescribeSObjectResult describe;
    private Map<String, Schema.DescribeFieldResult> describeFieldMap;
    private Map<String, Schema.SObjectField> objFieldMap;
    
	protected Schema.SObjectType sobjType;
    protected Set<String> queryFields;
    protected Map<String, Set<Schema.SObjectField>> queryFieldsMap;
    
    public Set<String> inaccessibleFields;
    
    public Schema.SObjectType getSObjectType(){
        return this.sobjType;
    }
    
    public List<String> getQueryFields(){
        return new List<String>(this.queryFields);
    }
    
    public Boolean checkObjectAccess(){
        if(this.sobjType == null){
            throw new ftf_QuerySelectorException('Attempted to check access to SObject before setting this.sobjType');
        }
        
        if(this.describe == null){
            this.describe = sobjType.getDescribe();
        }
        
        return this.describe.isAccessible();
    }
    
    public Boolean checkFieldAccess(){
        Boolean result;
        if(this.sobjType == null){
            throw new ftf_QuerySelectorException('Attempted to check access to SObject fields before setting this.sobjType');
        }
        
        result = true;
        if(this.queryFields == null || this.queryFields.isEmpty()){
            return result;
        }
        
        if(this.objFieldMap == null){
            if(this.describe == null){
                this.describe = this.sobjType.getDescribe();
            }
            
            this.objFieldMap = this.describe.fields.getMap();
        }
        
        for(String field :this.queryFields){
            if(!this.objFieldMap.containsKey(field)){
                
            }
            
            if(!this.describeFieldMap.containsKey(field)){
                this.describeFieldMap.put(field, this.objFieldMap.get(field).getDescribe());
            }
            
            if(!this.describeFieldMap.get(field).isAccessible()){
                result = false;
                inaccessibleFields.add(field);
            }
        }
        
        return result;
    }
    
    public virtual List<SObject> selectById(Set<Id> idSet){
        List<SObject> resultList;
        
        String query = String.format(
            'SELECT {0} ' + 
            'FROM {1} ' + 
            'WHERE Id IN :idSet',
            new List<String>{this.makeFieldString(), this.describe.getName()}
        );
        
        return resultList;
    }
    
    private String makeFieldString(){
        String result, prefix;
        List<String> tempResult = new List<String>();
		List<String> tempFieldNames;
        
        for(String objPath :this.queryFieldsMap.keySet()){
            tempFieldNames = new List<String>();
            prefix = String.isBlank(objPath) ? '' : objPath + '.';
            for(Schema.SObjectField sobjField :this.queryFieldsMap.get(objPath)){
                tempFieldNames.add(sobjField.getDescribe().getName());
            }
            
            tempResult.add(prefix + String.join(tempFieldNames, ', ' + prefix));
        }
        
        result = String.join(tempResult, ', ');
        
        return result;
    }
    
    public class ftf_QuerySelectorException extends System.Exception{}
}