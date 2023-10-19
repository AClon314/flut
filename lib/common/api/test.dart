void main(){
  var ii=false;
  asy()async{
    return true;
  }

  no(){
    var a=asy();
    print('no_a:$a');
  }

  yes(i){
    asy().then((value) {
      var a=value;
      print('yes_a:$a');
      i=value;
      print('ii0:$ii');
      ii=value;
      print('ii1:$ii');
      return a;
    });
  }
  yes1(){
    asy().then((value) => print('yes1_a:$value'));
  }

  yes2()async{
    var a=await asy();
    print('yes2_a:$a');
  }

  print('result0:${no()}');
  print('result1:${yes(ii)}');
  print('result2:${yes2()}');
  print('ii:$ii');
}