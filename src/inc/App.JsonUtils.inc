ROUTINE App.JsonUtils [Type=INC]
#; ver 20191127
#include %occReference

#define formatJSON 		"aelotwc"
#define formatJSONSQL	"tw"
#define formatDate		3
#define formatTime		7

#define toJSONClassMethod "toJSON"
#define updateClassMethod "updateIdFromObject"
#define IsNewJSON ##Expression($$$comClassDefined("%Library.DynamicAbstractObject"))

#if $$$IsNewJSON
    #define NewDynObj {}
    #define NewDynDTList []
    #define NewDynObjList $$$NewDynDTList
    #define Insert(%obj,%element) do %obj.%Push(%element)
    #define DynObjToJSON(%obj) w %obj.%ToJSON()
    #define ListToJSON(%obj) $$$DynObjToJSON(%obj)
    #define ListSize(%obj) %obj.%Size()
    #define ListGet(%obj,%i) %obj.%Get(%i-1)
    #define jsonClassIsLatestVersion %ClassIsLatestVersion 	
    						//usage: obj.$$$jsonClassIsLatestVersion()
    #define jsonExtends %Extends							
    						//usage: {}.$$$jsonExtends(classname) 
    #define jsonFromJSON %FromJSON							
    						//usage: {}.$$$jsonFromJSON(string) 
    #define jsonGetIterator %GetIterator 					
    						//usage: obj.$$$jsonGetIterator()
	#define jsonGetNext %GetNext 					
    						//usage: iterator.$$$jsonGetNext(.key, .value)
	#define jsonIsA %IsA									
    						//usage: obj.$$$jsonIsA(className)
    #define jsonToJSON %ToJSON								
    						//usage: obj.$$$jsonToJSON()
    #define jsonGet %Get									
    #define jsonNew %New									
    						//usage: obj.$$$jsonGet(key)
    #define jsonIsDefined %IsDefined						
    						//usage: obj.$$$jsonIsDefined(key) 
    #define jsonRemove %Delete								
    						//usage: obj.$$$jsonRemove(key)
    #define jsonSet %Set									
    						//usage: obj.$$$jsonSet(key, val)
    #define jsonSize %Size									
    						//usage: obj.$$$jsonSize()
    #define jsonPop %Pop									
    						//usage: obj.$$$jsonPop()
    #define jsonPush %Push									
    						//usage: obj.$$$jsonPush(val) 
	#define jsonAbstractClass %Library.AbstractDynamicObject
	#define jsonObjectClass %Library.DynamicObject
	#define jsonArrayClass %Library.DynamicArray
	
	#define jsonInitialArrayIndex 1
	
	#define jsonGetTypeOf %GetTypeOf
    						//usage: obj.$$$jsonGgetTypeOf()
#else
    #define NewDynObj ##class(%ZEN.proxyObject).%New()
    #define NewDynDTList ##class(%ListOfDataTypes).%New()
    #define NewDynObjList ##class(%ListOfObjects).%New()
    #define Insert(%obj,%element) do %obj.Insert(%element)
    #define DynObjToJSON(%obj) do %obj.%ToJSON()
    #define ListToJSON(%obj) do ##class(%ZEN.Auxiliary.jsonProvider).%ObjectToJSON(%obj)
    #define ListSize(%obj) %obj.Count()
    #define ListGet(%obj,%i) %obj.GetAt(%i)

   #define jsonClassIsLatestVersion $classIsLatestVersion 	
    						//usage: obj.$$$jsonClassIsLatestVersion()
    #define jsonExtends $extends							
    						//usage: {}.$$$jsonExtends(classname) 
    #define jsonFromJSON $fromJSON							
    						//usage: {}.$$$jsonFromJSON(string) 
    #define jsonGetIterator $getIterator 					
    						//usage: obj.$$$jsonGetIterator()
    #define jsonGetNext $getNext 					
    						//usage: iterator.$$$jsonGetNext(.key, .value)
    #define jsonIsA $isA									
    						//usage: obj.$$$jsonIsA(classname)
    #define jsonToJSON $toJSON								
    						//usage: obj.$$$jsonToJSON()
    #define jsonGet $get									
    #define jsonNew $new									
    						//usage: obj.$$$jsonGet(key)
    #define jsonIsDefined $isDefined						
    						//usage: obj.$$$jsonIsDefined(key) 
    #define jsonRemove $remove								
    						//usage: obj.$$$jsonRemove(key)
    #define jsonSet $set									
    						//usage: obj.$$$jsonSet(key, val)
    #define jsonSize $size									
    						// usage: obj.$$$jsonSize()
    #define jsonPop $pop									
    						//usage: obj.$$$jsonPop()
    #define jsonPush $push									
    						//usage: obj.$$$jsonPush(val) 
 	#define jsonAbstractClass %Library.AbstractObject
	#define jsonObjectClass %Library.Object
	#define jsonArrayClass %Library.Array
	#define jsonInitialArrayIndex 0
	#define jsonGetTypeOf $getTypeOf
    						//usage: obj.$$$jsonGgetTypeOf()
#endif


#def1arg jsonIsAbstract %IsA(##Quote($$$jsonAbstractClass))
							//usage: obj.$$$jsonIsAbstract
#def1arg jsonIsObject %IsA(##Quote($$$jsonObjectClass))
							//usage: obj.$$$jsonIsObject
#def1arg jsonIsArray %IsA(##Quote($$$jsonArrayClass))
							//usage: obj.$$$jsonIsArray
