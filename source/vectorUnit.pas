unit vectorUnit;

interface

uses sysutils, Windows;

type

  TVector = class
  private
    fVect: pointer;
    fItemSize: longword;
    function getItem(index: integer): pointer;
  public
    function count: integer;
    property items[index: integer]: Pointer read getItem;
    constructor create(vect: pointer; itemsize: longword);
  end;

implementation

type PPointer = ^pointer;

constructor TVector.create(vect: pointer; itemsize: longword);
begin
  fVect := vect;
  fItemSize := itemsize;
end;

function TVector.count: integer;
begin
  result := plongword(ptr(LongWord(fVect) + 4))^;
end;

function TVector.getItem(index: integer): pointer;
begin
  result := ptr(pLongword(fVect)^ + index * fitemsize);
end;
end.

