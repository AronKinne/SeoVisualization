class Tree {

  PVector origin;
  Tupel current;
  ArrayList<Tupel> tupels;
  ArrayList<PShape> lines;
  float w, ySpace;
  boolean split, reversed;
  int type, amtLayers;
  int mergeInd, mergeL;
  float innerInd;
  boolean mergeFirst;
  Tree small, sort;

  Tree(Tupel o) {
    this(o, 0, width * .5, 10, width, 150, false, 0);
  }

  private Tree(Tupel o, int type, float x, float y, float w, float ySpace, boolean reversed, int amtLayers) {
    origin = new PVector(x, y);
    tupels = new ArrayList<Tupel>();
    lines = new ArrayList<PShape>();
    tupels.add(o);
    current = tupels.get(0);
    this.w = w;
    this.ySpace = ySpace;
    this.type = type;
    small = null;
    sort = null;
    this.reversed = reversed;
    this.amtLayers = amtLayers;  // Only used if reversed == true
    mergeInd = 0;
    mergeL = -1; 
    innerInd = 0;
    mergeFirst = true;

    if (reversed) {
      for (int i = 1; i < amtLayers; i++) {
        for (int j = 0; j < (int)pow(2, i); j++) tupels.add(new Tupel());
      }
    }
  }

  void draw() {
    if ((small == null && sort == null) || type == 1 || type == 2) {
      for (int i = 0; i < tupels.size(); i++) {
        Tupel t = tupels.get(i);
        int layer = ceil(log(i + 2) / log(2)) - 1;

        t.draw(getPosFromIndex(i));
        if (!reversed)t.setValues(layer + 1, (int)pow(2, layer + 1));
      }

      for (PShape line : lines) shape(line);
    } else {
      small.draw();

      if (sort != null) {
        sort.draw();
      }
    }
  }

  PVector getPosFromIndex(int i) {
    if (!reversed) {
      int layer = ceil(log(i + 2) / log(2)) - 1;
      int maxPerLayer = (int)pow(2, layer);
      int index = floor(i - pow(2, layer) + 1);

      float x = origin.x - w * .5 + ((index + .5) * w / maxPerLayer);
      float y = origin.y + layer * ySpace;

      return new PVector(x, y);
    } else {
      int layer = ceil(log(i + 2) / log(2)) - 1;
      int maxPerLayer = (int)pow(2, layer);
      int index = floor(i - pow(2, layer) + 1);

      float x = origin.x - w * .5 + ((index + .5) * w / maxPerLayer);
      float y = origin.y - layer * ySpace;

      return new PVector(x, y);
    }
  }

  int getIndex(int layer, int n) {
    int sum = 0;
    for (int i = 0; i < layer; i++) {
      sum += (int)pow(2, i);
    }
    sum += n;
    return sum;
  }

  int getIndex(Tupel t) {
    for (int i = 0; i < tupels.size(); i++) {
      if (tupels.get(i) == t) return i;
    }
    return -1;
  }

  int getLayer(Tupel t) {
    return ceil(log(getIndex(t) + 2) / log(2)) - 1;
  }

  int getNumber(Tupel t) {
    return floor(getIndex(t) - pow(2, getLayer(t)) + 1);
  }

  void createLines(Tupel tc, Tupel tl, Tupel tr) {
    PVector pc = getPosFromIndex(getIndex(tc));
    PVector pl = getPosFromIndex(getIndex(tl));
    PVector pr = getPosFromIndex(getIndex(tr));

    PShape lineL = createShape();
    PShape lineR = createShape();

    if (type == 0) {
      lineL.setStroke(color(255, 0, 0));
      lineL.beginShape();
      lineL.vertex(pc.x - 30, pc.y + 20);
      lineL.vertex(pl.x, pl.y - 20);
      lineL.endShape();

      lineR.setStroke(color(0, 255, 0));
      lineR.beginShape();
      lineR.vertex(pc.x + 30, pc.y + 20);
      lineR.vertex(pr.x, pr.y - 20);
      lineR.endShape();
    } else if (type == 3) {
      lineL.setStroke(color(0, 0, 255));
      lineL.beginShape();
      lineL.vertex(pl.x, pl.y + 20);
      lineL.vertex(pc.x - 10, pc.y - 20);
      lineL.endShape();

      lineR.setStroke(color(0, 0, 255));
      lineR.beginShape();
      lineR.vertex(pr.x, pr.y + 20);
      lineR.vertex(pc.x + 10, pc.y - 20);
      lineR.endShape();
    } else if (type == 1) {
      lineL.setStroke(color(255, 0, 0));
      lineL.beginShape();
      lineL.vertex(pc.x - 10, pc.y + 20);
      lineL.vertex(pl.x, pl.y - 20);
      lineL.endShape();

      lineR.setStroke(color(0, 255, 0));
      lineR.beginShape();
      lineR.vertex(pc.x + 10, pc.y + 20);
      lineR.vertex(pr.x, pr.y - 20);
      lineR.endShape();
    }

    lines.add(lineL);
    lines.add(lineR);
  }

  PVector getChildren(Tupel t) {
    int i = getIndex(t); 
    int layer = ceil(log(i + 2) / log(2)) - 1; 
    int maxPerLayer = (int)pow(2, layer);  
    int index = floor(i - pow(2, layer) + 1);

    int noch = maxPerLayer - index - 1;  
    int schon = maxPerLayer - noch - 1;  

    int l = noch + 2 * schon + i + 1;  
    int r = l + 1; 

    return new PVector(l, r);
  }

  Tupel getParent(Tupel t) {
    if (getLayer(t) > 0) {
      int layer = getLayer(t) - 1;
      int number = floor(getNumber(t) / 2);
      return tupels.get(getIndex(layer, number));
    }
    return null;
  }

  boolean hasChildren(Tupel t) {
    if (getChildren(t).y < tupels.size()) {
      return tupels.get((int)getChildren(t).x).size > 0;
    } 
    return false;
  }

  void addNext() {
    Tupel t = sort.tupels.get(getIndex(mergeL, mergeInd));
    Tupel cl = sort.tupels.get((int)sort.getChildren(t).x);
    Tupel cr = sort.tupels.get((int)sort.getChildren(t).y);
    int childSize = cl.size + cr.size;

    if (sort.hasChildren(t)) {
      if (t.size < childSize) {
        if (mergeFirst) {
          sort.createLines(t, cl, cr);
          for (int i = 0; i < cl.size; i++) cl.states.set(i, 0);
          for (int i = 0; i < cr.size; i++) cr.states.set(i, 0);
          mergeFirst = false;
        } else if (innerInd / 2 == floor(innerInd / 2)) {
          t.add(cl.numbers.get(floor(innerInd / 2)));
          cl.states.set(floor(innerInd / 2), 2);
          t.states.set((int)innerInd, 2);
          innerInd++;
        } else {
          t.add(cr.numbers.get(floor(innerInd / 2)));
          cr.states.set(floor(innerInd / 2), 1);
          t.states.set((int)innerInd, 1);
          innerInd++;
        }
        if (t.size < childSize) {
          mergeInd--;
        } else {
          innerInd = 0;
          mergeFirst = true;
        }
      } else {
        innerInd = 0;
        mergeFirst = true;
      }
    } else {
      t.add(tupels.get(getIndex(mergeL, mergeInd)).numbers.get(0));
      innerInd = 0;
      mergeFirst = true;
    }
  }

  void next() {
    if (!done) {
      if (type == 0) {
        if (split) {
          if (small != null) {
            if (sort == null) {

              int lastLayer = ceil(log(tupels.size() + 1) / log(2)) - 1;
              float ownHeight = (lastLayer + 1) * 100;
              float smallHeight = small.origin.y + (lastLayer + 1) * small.ySpace;
              sort = new Tree(new Tupel(), 3, origin.x, smallHeight + ownHeight - 50, width, 100, true, lastLayer + 1);

              mergeL = lastLayer;
              mergeInd = -1;

              for (int i = 0; i < tupels.size(); i++) {
                Tupel t = tupels.get(i);
                if (getLayer(t) == lastLayer) {
                  int n = getNumber(t);
                  if (n > mergeInd) {
                    mergeInd = n;
                    break;
                  }
                }
              };

              sort.tupels.add(getIndex(mergeL, mergeInd), tupels.get(getIndex(mergeL, mergeInd)).copy());

              for (int i = 0; i < tupels.size(); i++) {
                Tupel t = tupels.get(i);
                if (getLayer(t) == lastLayer) {
                  int n = getNumber(t);
                  if (n > mergeInd) {
                    mergeInd = n;
                    break;
                  }
                }
              };
            } else {
              int lastLayer = ceil(log(tupels.size() + 1) / log(2)) - 1;
            outer:
              if (mergeL == lastLayer) {
                sort.tupels.set(getIndex(mergeL, mergeInd), tupels.get(getIndex(mergeL, mergeInd)).copy());

                for (int i = 0; i < tupels.size(); i++) {
                  Tupel t = tupels.get(i);
                  if (getLayer(t) == mergeL && t.size > 0) {
                    int n = getNumber(t);
                    if (n > mergeInd) {
                      mergeInd = n;
                      break outer;
                    }
                  }
                };

                mergeL--;
                mergeInd = 0;
              } else {
                if (mergeInd == 0) {
                  addNext();
                  mergeInd++;
                } else {
                  addNext();

                  if (mergeInd + 1 < pow(2, mergeL)) {
                    mergeInd++;
                  } else {
                    mergeInd = 0;
                    mergeL--;
                    if (mergeL < 0) {
                      println("Done!");
                      Tupel o = sort.tupels.get(0);
                      for (int i = 0; i < o.size; i++) o.states.set(i, 3);
                      background(255);
                      draw();
                      done = true;
                      noLoop();
                    };
                  }
                }
              }
            }
          } else {
            small = new Tree(tupels.get(0).copy(), 1, origin.x, origin.y, w, 50, false, 0);
            for (int i = 1; i < tupels.size(); i++) small.tupels.add(tupels.get(i).copy());
            for (Tupel t : small.tupels) {
              if (small.hasChildren(t)) {
                PVector c = small.getChildren(t);
                small.createLines(t, small.tupels.get((int)c.x), small.tupels.get((int)c.y));
              }
            }
          }
        } else if (!current.showSEO) {
          current.showSEO = true;
        } else if (current.splitInd < 0) {
          Tupel left = new Tupel();
          Tupel right = new Tupel();
          PVector children = getChildren(current);
          while (children.x > tupels.size()) tupels.add(new Tupel());
          tupels.add((int)children.x, left);
          tupels.add((int)children.y, right);
          createLines(current, left, right);
          current.splitInd = 0;
        } else if (current.splitInd < current.size) {
          if (current.isNextEven()) {
            current.states.set(current.splitInd - 1, 1); 
            tupels.get(tupels.size() - 1).add(current.numbers.get(current.splitInd - 1));
          } else {
            current.states.set(current.splitInd - 1, 2); 
            tupels.get(tupels.size() - 2).add(current.numbers.get(current.splitInd - 1));
          }

          if (current.splitInd == current.size || current.size == 1) {
            split = true;
            for (int i = 0; i < tupels.size(); i++) {
              Tupel t = tupels.get(i); 
              if (t.splitInd < 0 && t.size > 1) {
                current = tupels.get(i);
                split = false;
                break;
              }
            }
          }
        }
      }
    }
  }
}