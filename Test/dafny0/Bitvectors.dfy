// RUN: %dafny /compile:3 /print:"%t.print" /rprint:- /env:0 "%s" > "%t"
// RUN: %diff "%s.expect" "%t"

method M(a: bv1, b: bv32) returns (c: bv32, d: bv1)
{
  c := b;
  d := a;
  var x := 5000;
  c := x;
  var y := 4000;
  y := c;
}

method Main() {
  var x := 4000;
  var y := 4000;
  var z: bv32;
  var w: bv32;
  if x == y {
    z := x;
  } else {
    w := y;
  }
  print x, " ", y, " ", z, " ", w, "\n";
  var t, u, v := BitwiseOperations();
  print t, " ", v, " ", v, "\n";
  DoArith32();
  var unry := Unary(5);
  print "bv16: 5 - 2 == ", unry, "\n";
  unry := Unary(1);
  print "bv16: 1 - 2 == ", unry, "\n";
  
  SummoTests();
  
  var zz0;
  var zz1 := Bv0Stuff(zz0, 0);
  print zz0, " ", zz1, "\n";
  print zz0 < zz1, " ", zz0 <= zz1, " ", zz0 >= zz1, " ", zz0 > zz1, "\n";
  
  TestCompilationTruncations();
}

method BitwiseOperations() returns (a: bv47, b: bv47, c: bv47)
{
  b, c := 2053, 1099;
  a := b & c;
  a := a | a | (b & b & c & (a ^ b ^ c) & a);
}

method Arithmetic(x: bv32, y: bv32) returns (r: bv32, s: bv32)
  ensures r == x + y && s == y - x
{
  r := x + y;
  s := y - x;
}

method DoArith32() {
  var r, s := Arithmetic(65, 120);
  print r, " ", s, "\n";
  var x, y := 0x7FFF_FFFF, 0x8000_0003;
  r, s := Arithmetic(x, y);
  assert r == 2 && s == 4;
  print r, " ", s, "\n";
  assert x < y && x <= y && y >= x && y > x;
  print "Comparisons: ", x < y, " ", x <= y, " ", x >= y, " ", x > y, "\n";
}

method Unary(x: bv16) returns (y: bv16)
  ensures y == x - 2
{
  // This method takes a long time (almost 20 seconds) to verify
  y := -(-!-!!--(x));
  y := !-y;
  var F := 0xffff;
  calc {
    y;
    !--(-!-!!--(x));
    F - ---!-!!--x;
    { assert ---!-!!--x == -!-!!--x; }
    F - -!-!!--x;
    F + !-!!--x;
    F + F - -!!--x;
    F + F + !!--x;
    { assert !!--x == --x == x; }
    F + F + x;
    x - 2;
  }
}

method SummoTests() {
  var a: bv64 := 5;
  a := 2 * 2 * 2 * (2 * 2) * a * 2 * (2 * 2 * 2) * 2;  // shift left 10 bits
  var b := a / 512;  // b is a shifted right 9 bits, so it is 5 shifted left 1 bit
  assert b == 10;
  assert b / 3 == 3 && b / 4 == 2;
  assert b % 3 == 1 && b % 4 == 2;
  print b / 3, " ", b % 4, "\n";
}

method Bv0Stuff(x: bv0, y: bv0) returns (z: bv0)
  ensures z == 0  // after all, there is only one value
{
  // This will make sure verification and compilation won't crash for these expressions
  z := x + y;
  z := x * z - y;
  z := (x ^ z) | (y & y);
  z := !z + -z;
}

// --------------------------------------

method TestCompilationTruncations()
{
  M67(-1, 3);
  M64(-1, 3);
  M53(-1, 3);
  M33(-1, 3);
  M32(-1, 3);
  M31(-1, 3);
  M16(-1, 3);
  M15(-1, 3);
  M8(-1, 3);
  M6(-1, 3);
  M1(1, 1);
  M0(0, 0);

  P2(3, 2);
}

method M67(a: bv67, b: bv67)
{
  print "bv67:  ", a, " + ", b, " == ", a+b, "     - ", b, " == ", -b, "     !! ", b, " == ! ", !b, " == ", !!b, "\n";
}

method M64(a: bv64, b: bv64)
{
  print "bv64:  ", a, " + ", b, " == ", a+b, "     - ", b, " == ", -b, "     !! ", b, " == ! ", !b, " == ", !!b, "\n";
}

method M53(a: bv53, b: bv53)
{
  print "bv53:  ", a, " + ", b, " == ", a+b, "     - ", b, " == ", -b, "     !! ", b, " == ! ", !b, " == ", !!b, "\n";
}

method M33(a: bv33, b: bv33)
{
  print "bv33:  ", a, " + ", b, " == ", a+b, "     - ", b, " == ", -b, "     !! ", b, " == ! ", !b, " == ", !!b, "\n";
}

method M32(a: bv32, b: bv32)
{
  print "bv32:  ", a, " + ", b, " == ", a+b, "     - ", b, " == ", -b, "     !! ", b, " == ! ", !b, " == ", !!b, "\n";
}

method M31(a: bv31, b: bv31)
{
  print "bv31:  ", a, " + ", b, " == ", a+b, "     - ", b, " == ", -b, "     !! ", b, " == ! ", !b, " == ", !!b, "\n";
}

method M16(a: bv16, b: bv16)
{
  print "bv16:  ", a, " + ", b, " == ", a+b, "     - ", b, " == ", -b, "     !! ", b, " == ! ", !b, " == ", !!b, "\n";
}

method M15(a: bv15, b: bv15)
{
  print "bv15:  ", a, " + ", b, " == ", a+b, "     - ", b, " == ", -b, "     !! ", b, " == ! ", !b, " == ", !!b, "\n";
}

method M8(a: bv8, b: bv8)
{
  print "bv8:  ", a, " + ", b, " == ", a+b, "     - ", b, " == ", -b, "     !! ", b, " == ! ", !b, " == ", !!b, "\n";
}

method M6(a: bv6, b: bv6)
{
  print "bv6:  ", a, " + ", b, " == ", a+b, "     - ", b, " == ", -b, "     !! ", b, " == ! ", !b, " == ", !!b, "\n";
}

method M1(a: bv1, b: bv1)
{
  print "bv1:  ", a, " + ", b, " == ", a+b, "     - ", b, " == ", -b, "     !! ", b, " == ! ", !b, " == ", !!b, "\n";
}

method M0(a: bv0, b: bv0)
{
  print "bv0:  ", a, " + ", b, " == ", a+b, "     - ", b, " == ", -b, "     !! ", b, " == ! ", !b, " == ", !!b, "\n";
}

method P2(a: bv2, b: bv2)
  requires b != 0
{
  print "bv2:\n";
  print "  ", a, " + ", b, " == ", a+b, "\n";
  print "  ", a, " - ", b, " == ", a-b, "\n";
  print "  ", a, " * ", b, " == ", a*b, "\n";
  print "  ", a, " / ", b, " == ", a/b, "\n";
  print "  ", a, " % ", b, " == ", a%b, "\n";
}
