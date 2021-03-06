program DNASequenceAlignment;
uses //useful libraries
 Sysutils, math,
 crt;
var
    matrixFirst:array of integer;   // dynamic array
    fileInput:textfile;
    lineTxt:string;
    match_award:integer=10;
    mismatch_penalty:integer=-5;
    gap_penalty:integer=-5;
    myString:string;

type
  MatrixDNA = array of array of integer;

procedure printMatrix(mat:MatrixDNA);
var i,j,l,m:integer;
begin
  i:= 0;
  j:= 0;
  //length of matrix is equal to lines quantity, because the matrix is an array
  //of arrays
  l:=Length(mat);
  writeln('[');
  //first loop
  while i <> l do
  begin
    m := Length(mat[i]);
    //second loop
    while j <> m do
    begin
      //print cell value
      write(mat[i][j]);
      write(' ');
      //increase the j value in one, until j is equal to m
      j:=j+1;
      end;
    //increase the i value in one, until i is equal to l
    i:= i + 1;
    j := 0;
    writeln('');
    end;
  write(']');

  end;

function getMatrix(p:integer;n:integer):MatrixDNA;
   var i,j,l,m:integer;
   mat:MatrixDNA;
   begin
     i:= 0;
     j:= 0;
     setLength(mat,p,n);
     //length of matrix is equal to lines quantity, because the matrix is an array
     //of arrays
     l:=Length(mat);
     while i <> l do
     begin
       m := Length(mat[i]);
       while j <> m do
       begin
         mat[i][j]:=0;
         //increase the j value in one, until j is equal to m
         j:=j+1;
         end;
       //increase the i value in one, until i is equal to l
       i:= i + 1;
       j := 0;
       end;
     getMatrix:=mat;
end;
function invertString(align:String):String;
var
  t:string;
  i:byte;
  begin
    for i:=length(align) downto 1 do
      t:=t+align[i];
    writeln(t);
    invertString:=t;

    end;
function readFile(fileName:string):String;
var
  output:string;
  begin
  assignfile (fileInput, fileName);
  try
    reset(fileInput);
    readln(fileInput,lineTxt);
    output:=lineTxt;
    writeln(lineTxt);
    close(fileInput);
  except
    writeln('no existe');
    end;
  readFile:=output;
end;

function matchScore(alpha:string;beta:string):integer;
     begin
       if boolean( CompareText(alpha,beta) = 0 ) then
       begin
            matchScore:=match_award;
       end
       else if boolean(CompareText(alpha,'-') = 0) or boolean(CompareText(beta,'-') = 0) then
       begin
            matchScore:=gap_penalty;
       end
       else
           matchScore:=mismatch_penalty;
     end;

function bestAlignment(align1:string;align2:string):string;
var
  size,i,j,found,score,identity:integer;
  symbol,seq1,seq2,best,best2:string;

begin
i:=0;
j:=0;
found:=0;
score:=0;
symbol:='';
identity:=0;
size:=length(align1);
seq1:=invertString(align1);
seq2:=invertString(align2);

while i<>size do
begin
      if boolean( CompareText(seq1[i],seq2[2]) = 0 ) then
       begin
            symbol:=symbol + seq1[i];
            identity:=identity+1;
            score:=score + matchScore(seq1[i],seq2[i]);
       end
      else if (CompareText(seq1[i],seq2[2]) <> 0)
      AND (CompareText(seq1[i],'-') <> 0) AND
      (CompareText(seq2[i],'-') <> 0) then
       begin
            symbol:=symbol+'';
            found:=0;
            score:=score+matchScore(seq1[i],seq2[i]);
            end
      else if (CompareText(seq1[i],'-') = 0) OR
      (CompareText(seq2[i],'-') = 0) then
       begin
            symbol:=symbol+'';
            score:=score+gap_penalty;
            end;
      i:=i+1;
      end;
      identity:=100;
      bestAlignment:=seq1+''+seq2;

  end;
procedure needle(seq1:string;seq2:string);
var
  i,j,m,n,match,delete,insert,score_current:integer;
  score_diagonal,score_up,score_left:integer;
  test: real;
  score:MatrixDNA;
  align1,align2:string;
begin
m:=length(seq1);
n:=length(seq2);
i:=0;
j:=0;
match:=0;
delete:=0;
insert:=0;
score:=getMatrix(m+1,n+1);
align1:='';
align2:='';

//calculate DP TABLE
while i<> (m+1) do
begin
     score[i][0]:=gap_penalty*i;
     i:=i+1;
end;

j:=0;
while j<> (n+1) do
begin
     score[0][j]:=gap_penalty*j;
     j:=j+1;
end;

i:=1;
j:=1;
while i<> (m+1) do
begin
  while j<> (n+1) do
  begin
    match:=score[i-1][j-1]+ matchScore(seq1[i],seq2[j]);
    delete:=score[i-1][j] +gap_penalty;
    insert:=score[i][j-1] +gap_penalty;
    score[i][j]:= Max(match,Max(delete,insert));
    j:=j+1;
  end;
  i:=i+1;
  j:=1;
  end;

//TRACEBACK AND COMPUTE THE ALIGNMENT
i:=m;
j:=n;
while boolean(i>0) AND boolean(j>0) do
begin
  score_current:=score[i][j];
  score_diagonal:=score[i-1][j-1] ;
  score_up:= score[i][j-1];
  score_left:=score[i-1][j];

  if score_current= score_diagonal+matchScore(seq1[i],seq2[j]) then
  begin
       align1:=align1+seq1[i];
       align2:=align2+seq2[j];
       i:= i-1;
       j:= j-1;
       end
  else if score_current=score_left+gap_penalty then
       begin
       align1:=align1+seq1[i];
       align2:=align2+'-';
       i:= i-1;
       end
  else
      begin
      align1:=align1+'-';
      align2:=align2+seq2[j];
      j:= j-1;
      end;
  end;

//FINISH TRACING UP TO THE TOP LEFT CELL
while i>0 do
begin
     align1:=align1+seq1[i-1];
     align2:=align2+'-';
     i:= i-1;
end;

while j>0 do
begin
     align1:=align1+'-';
     align2:=align2+seq2[j-1];
     j:= j-1;
end;

bestAlignment(align1,align2);



end;



begin
    needle('GATTACA','GCATGCU');
    readln;

end.
