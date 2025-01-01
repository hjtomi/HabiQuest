void printWarning(text) {
  print('\x1B[33m$text\x1B[0m');
}

void printError(text) {
  print('\x1B[31m$text\x1B[0m');
}

void printMessage(text) {
  print('\x1B[32m$text\x1B[0m');
}