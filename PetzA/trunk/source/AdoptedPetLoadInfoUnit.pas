unit AdoptedPetLoadInfoUnit;

interface

type
 TAdoptedPetLoadInfo=class
 public

 end;

 function s_AdoptedPetLoadInfo:TAdoptedPetLoadInfo;

implementation

 function s_AdoptedPetLoadInfo:TAdoptedPetLoadInfo;
 begin
  result:=TAdoptedPetLoadInfo(Ptr($6391C0));
 end;

end.
