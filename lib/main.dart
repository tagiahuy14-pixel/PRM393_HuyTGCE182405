int calculateTotal(int a, int b) {
  int total = a + b;
  return total;
}

double calculateAverage(int a, int b) {
  return (a + b) / 2;
}

void processNumber(int number, Function(int) callback) {
  callback(number);
}

void printNumber(int value) {
  print("Value is: $value");
}

void process(int number, Function(int) callback) {
  callback(number);
}

void main() {
  int result = calculateTotal(5, 7);
  print(result);

  double avg = calculateAverage(6, 8);
  print("Average: $avg");

  processNumber(10, printNumber);

  process(5, (value) {
    print("Anonymous value: $value");
  });
}
