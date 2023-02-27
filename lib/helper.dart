class TypesHelper {
  static String roundNum(double amount) {
    String result = '';
    String num = amount.toString();
    if (num.indexOf('.') > -1) {
      int index = num.indexOf('.');
      if (num.length > index + 3) {
        result = num.substring(0, index + 3);
      } else if(num.length == (index+2)){
        result = num+'0';
      }else {
        result = num;
      }
    } else {
      result = '$num.00';
    }

    return result;
  }
}
