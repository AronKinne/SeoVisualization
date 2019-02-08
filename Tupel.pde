class Tupel {

  ArrayList<Integer> numbers;
  ArrayList<Integer> states;
  int size;
  int s, e, o;
  boolean showSEO;
  int splitInd;

  Tupel(int size) {
    this.size = size;
    numbers = new ArrayList<Integer>();
    states = new ArrayList<Integer>();
    splitInd = -1;

    for (int i = 0; i < size; i++) {
      numbers.add(i + 1);
      states.add(0);
    }

    for (int i = size - 1; i >= 0; i--) {
      int j = (int)random(size);

      int tmp = numbers.get(j);
      numbers.set(j, numbers.get(i));
      numbers.set(i, tmp);
    }
  }
  
  void log() {
    for(Integer i : numbers) print(i + " ");
    println();
  }
  
  Tupel copy() {
    Tupel r = new Tupel();
    
    for(int i = 0; i < numbers.size(); i++) r.add(numbers.get(i));
    
    return r;
  }

  Tupel(int... in) {
    numbers = new ArrayList<Integer>();
    states = new ArrayList<Integer>();
    splitInd = -1;

    for (Integer i : in) {
      numbers.add(i);
      states.add(0);
    }

    size = numbers.size();
  }

  void add(int v) {
    numbers.add(v);
    states.add(0);
    size++;
  }

  void setValues(int s, int e) {
    this.s = s;
    this.e = e;

    o = Integer.MAX_VALUE;
    for (int i = 0; i < numbers.size(); i++) {
      if (numbers.get(i) <= e) o = min(o, e - numbers.get(i));
    }
  }

  boolean isNextEven() {
    float v = numbers.get(splitInd++);
    v = (v + o) / e;
    return v == floor(v);
  }

  void draw(PVector pos) {
    textAlign(CENTER, CENTER);
    textSize(25);
    for (int i = 0; i < numbers.size(); i++) {
      int v = numbers.get(i);
      int st = states.get(i);
      fill(st == 1 ? color(0, 255, 0) : (st == 2 ? color(255, 0, 0) : (st == 3 ? color(0, 0, 255) : 0)));
      text(v + "", pos.x - size * .5 * 40 + ((i + .5) * size * 40 / size), pos.y);
    }

    if (showSEO) {
      textSize(20);
      fill(0);
      text("s = " + s, pos.x, pos.y + 25);
      text("e = " + e, pos.x, pos.y + 45);
      text("o = " + o, pos.x, pos.y + 65);
    }
  }
}