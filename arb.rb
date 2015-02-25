require "formula"

# TODOs: 
# - Add Arb-FLINT integration in flint formula, setting Arb optional
# - (?) Add possibility to choose MPIR in place of GMP

class Arb < Formula
  homepage "http://fredrikj.net/arb/index.html"
  url "https://github.com/fredrik-johansson/arb/archive/2.5.0.tar.gz"
  sha1 "ba51573e0c50250bbb16bfca027dc26531347f12"
  head "https://github.com/fredrik-johansson/arb.git"

  depends_on "gmp"
  depends_on "mpfr"
  depends_on "flint"

  # Will be enabled once the new stable (with patched tests) is released
  # some of the tests in 2.5.0 are broken because they call not yet implemented
  # methods
  # option "with-check", "Enable build-time checking (not recommended)"

  def install
    system "./configure", "--prefix=#{prefix}"
    # We need to remove this line to have 2.5.0 compiled on OSX
    # it is fixed in the new version, this line will disappear then
    inreplace "Makefile", "$(QUIET_AR) $(AR) rcs libarb.a $(OBJS);", ""
    system "make"
    # Will be enabled once the new stable (with patched tests) is released
    # see above
    # system "make", "check" if build.with? "check"
    system "make", "install"
  end

  test do
    (testpath / "test.c").write <<-EOS.undent
      #include <stdio.h>
      #include <arb.h>

      int main()
      {
        arb_t x;
        arb_init(x);
        arb_const_pi(x, 50 * 3.33);
        arb_printn(x, 50, 0); printf("\n");
        printf("Computed with arb-%s\n", arb_version);
        arb_clear(x);

        return EXIT_SUCCESS;
      }
    EOS
    system ENV.cc, "test.c", "-larb", "-lflint", "-I#{Formula['flint'].include}/flint", "-o", "test"
    system "./test"
  end
end
