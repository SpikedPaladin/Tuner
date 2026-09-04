void test_from_variant_type() {
    // Null input
    assert(Tuner.from_variant_type(null) == Type.INVALID);

    // Valid mappings
    assert(Tuner.from_variant_type(VariantType.BOOLEAN) == Type.BOOLEAN);
    assert(Tuner.from_variant_type(VariantType.BYTE) == Type.UCHAR);
    assert(Tuner.from_variant_type(VariantType.DOUBLE) == Type.DOUBLE);
    assert(Tuner.from_variant_type(VariantType.INT32) == Type.INT);
    assert(Tuner.from_variant_type(VariantType.INT64) == Type.INT64);
    assert(Tuner.from_variant_type(VariantType.STRING) == Type.STRING);
    assert(Tuner.from_variant_type(VariantType.STRING_ARRAY) == typeof(string[]));
    assert(Tuner.from_variant_type(VariantType.UINT32) == Type.UINT);
    assert(Tuner.from_variant_type(VariantType.UINT64) == Type.UINT64);
    assert(Tuner.from_variant_type(VariantType.VARIANT) == Type.VARIANT);

    // Unknown type -> INVALID
    var unknown = new VariantType("q"); // non‑existent type string
    assert(Tuner.from_variant_type(unknown) == Type.INVALID);
}

void test_to_variant_type() {
    // INVALID -> null
    assert(Tuner.to_variant_type(Type.INVALID) == null);

    // Valid mappings
    assert(Tuner.to_variant_type(Type.BOOLEAN).equal(VariantType.BOOLEAN));
    assert(Tuner.to_variant_type(Type.UCHAR).equal(VariantType.BYTE));
    assert(Tuner.to_variant_type(Type.DOUBLE).equal(VariantType.DOUBLE));
    assert(Tuner.to_variant_type(Type.INT).equal(VariantType.INT32));
    assert(Tuner.to_variant_type(Type.INT64).equal(VariantType.INT64));
    assert(Tuner.to_variant_type(Type.STRING).equal(VariantType.STRING));
    assert(Tuner.to_variant_type(typeof(string[])).equal(VariantType.STRING_ARRAY));
    assert(Tuner.to_variant_type(Type.UINT).equal(VariantType.UINT32));
    assert(Tuner.to_variant_type(Type.UINT64).equal(VariantType.UINT64));
    assert(Tuner.to_variant_type(Type.VARIANT).equal(VariantType.VARIANT));

    // Unhandled type -> null
    assert(Tuner.to_variant_type(Type.CHAR) == null);
}

void test_variant_to_double() {
    // Direct double
    var v_double = new Variant.double(3.14);
    assert(Tuner.variant_to_double(v_double) == 3.14);

    // Signed integers
    var v_int16 = new Variant.int16(42);
    assert(Tuner.variant_to_double(v_int16) == 42.0);
    var v_int32 = new Variant.int32(-100);
    assert(Tuner.variant_to_double(v_int32) == -100.0);
    var v_int64 = new Variant.int64(12345678901234L);
    assert(Tuner.variant_to_double(v_int64) == 12345678901234.0);

    // Unsigned integers
    var v_uint16 = new Variant.uint16(65535);
    assert(Tuner.variant_to_double(v_uint16) == 65535.0);
    var v_uint32 = new Variant.uint32(4000000000U);
    assert(Tuner.variant_to_double(v_uint32) == 4000000000.0);
    var v_uint64 = new Variant.uint64(18446744073709551615UL);
    assert(Tuner.variant_to_double(v_uint64) == 18446744073709551615.0);

    // Unsupported type -> 0
    var v_string = new Variant.string("hello");
    assert(Tuner.variant_to_double(v_string) == 0.0);
}

void test_value_to_string() {
    var val_bool = Value(Type.BOOLEAN);
    val_bool.set_boolean(true);
    assert(Tuner.value_to_string(val_bool) == "true");

    var val_char = Value(Type.CHAR);
    val_char.set_schar(65);
    assert(Tuner.value_to_string(val_char) == "65");// ASCII code

    var val_uchar = Value(Type.UCHAR);
    val_uchar.set_uchar(255);
    assert(Tuner.value_to_string(val_uchar) == "255");

    var val_int = Value(Type.INT);
    val_int.set_int(-123);
    assert(Tuner.value_to_string(val_int) == "-123");

    var val_int64 = Value(Type.INT64);
    val_int64.set_int64(4398046511104);
    assert(Tuner.value_to_string(val_int64) == "4398046511104");

    var val_double = Value(Type.DOUBLE);
    val_double.set_double(2.71828);
    assert(Tuner.value_to_string(val_double) == "2.71828");

    var val_float = Value(Type.FLOAT);
    val_float.set_float(1.5F);
    assert(Tuner.value_to_string(val_float) == "1.5");

    var val_uint = Value(Type.UINT);
    val_uint.set_uint(3000000000U);
    assert(Tuner.value_to_string(val_uint) == "3000000000");

    var val_uint64 = Value(Type.UINT64);
    val_uint64.set_uint64(18446744073709551615UL);
    assert(Tuner.value_to_string(val_uint64) == "18446744073709551615");

    var val_string = Value(Type.STRING);
    val_string.set_string("test");
    assert(Tuner.value_to_string(val_string) == "test");

    // Unsupported type -> null
    var val_obj = Value(typeof(Object));
    assert(Tuner.value_to_string(val_obj) == null);
}

void test_convert_from_value() {
    // Boolean
    var val_bool = Value(Type.BOOLEAN);
    val_bool.set_boolean(true);
    var v = Tuner.convert_from_value(val_bool, VariantType.BOOLEAN);
    assert(v != null && v.get_boolean() == true);

    // Byte from signed/unsigned char
    var val_char = Value(Type.CHAR);
    val_char.set_schar(100);
    v = Tuner.convert_from_value(val_char, VariantType.BYTE);
    assert(v != null && v.get_byte() == 100);

    var val_uchar = Value(Type.UCHAR);
    val_uchar.set_uchar(200);
    v = Tuner.convert_from_value(val_uchar, VariantType.BYTE);
    assert(v != null && v.get_byte() == 200);

    // String -> various
    var val_str = Value(Type.STRING);
    val_str.set_string("hello");
    v = Tuner.convert_from_value(val_str, VariantType.STRING);
    assert(v != null && v.get_string() == "hello");
    v = Tuner.convert_from_value(val_str, VariantType.BYTESTRING);
    assert(v != null && v.get_bytestring() == "hello");

    // Signature
    val_str.set_string("i");
    v = Tuner.convert_from_value(val_str, VariantType.SIGNATURE);
    assert(v != null && v.get_string() == "i");

    // Object path
    val_str.set_string("/org/freedesktop/DBus");
    v = Tuner.convert_from_value(val_str, VariantType.OBJECT_PATH);
    assert(v != null && v.get_string() == "/org/freedesktop/DBus");

    // String array
    var val_strv = Value(typeof(string[]));
    string[] words = {"one", "two"};
    val_strv.set_boxed(words);
    v = Tuner.convert_from_value(val_strv, VariantType.STRING_ARRAY);
    assert(v != null && v.get_strv()[0] == "one" && v.get_strv()[1] == "two");

    // Integer conversions (test some ranges)
    var val_int = Value(Type.INT);
    val_int.set_int(32767); // max int16
    v = Tuner.convert_from_value(val_int, VariantType.INT16);
    assert(v != null && v.get_int16() == 32767);
    v = Tuner.convert_from_value(val_int, VariantType.UINT16);
    assert(v != null && v.get_uint16() == 32767);

    val_int.set_int(70000);
    v = Tuner.convert_from_value(val_int, VariantType.UINT16);
    assert(v == null); // out of range

    // Float conversions
    var val_double = Value(Type.DOUBLE);
    val_double.set_double(3.14);
    v = Tuner.convert_from_value(val_double, VariantType.DOUBLE);
    assert(v != null && v.get_double() == 3.14);
    v = Tuner.convert_from_value(val_double, VariantType.INT32);
    assert(v != null && v.get_int32() == 3); // truncated
}

void test_convert_to_value() {
    Value val = Value(Type.BOOLEAN);
    var v_bool = new Variant.boolean(false);
    assert(Tuner.convert_to_value(ref val, v_bool) == true);
    assert(val.get_boolean() == false);

    // INT target from signed variant
    val.unset();
    val.init(Type.INT);
    var v_int16 = new Variant.int16(42);
    assert(Tuner.convert_to_value(ref val, v_int16) == true);
    assert(val.get_int() == 42);

    // Out‑of‑range for INT
    val.unset();
    val.init(Type.INT);
    var v_int64_big = new Variant.int64(int64.MAX);
    assert(Tuner.convert_to_value(ref val, v_int64_big) == false);  // because l > int.MAX

    // UINT target
    val.unset();
    val.init(Type.UINT);
    var v_uint16 = new Variant.uint16(1000);
    assert(Tuner.convert_to_value(ref val, v_uint16) == true);
    assert(val.get_uint() == 1000);

    // String target
    val.unset();
    val.init(Type.STRING);
    var v_str = new Variant.string("hello");
    assert(Tuner.convert_to_value(ref val, v_str) == true);
    assert(val.get_string() == "hello");

    // String array target
    val.unset();
    val.init(typeof(string[]));
    var v_strv = new Variant.strv({"a", "b"});
    assert(Tuner.convert_to_value(ref val, v_strv) == true);
    var result = (string**) val.get_boxed();
    assert(result[0] == "a" && result[1] == "b");

    // BYTESTRING
    val.unset();
    val.init(Type.STRING);
    var v_bytestr = new Variant.bytestring("bytes");
    assert(Tuner.convert_to_value(ref val, v_bytestr) == true);
    assert(val.get_string() == "bytes");
}

void test_convert_from_int() {
    var val_int = Value(Type.INT);
    val_int.set_int(123);

    // Valid conversions
    var v = Tuner.convert_from_int(val_int, VariantType.INT16);
    assert(v != null && v.get_int16() == 123);

    v = Tuner.convert_from_int(val_int, VariantType.UINT32);
    assert(v != null && v.get_uint32() == 123);

    v = Tuner.convert_from_int(val_int, VariantType.DOUBLE);
    assert(v != null && v.get_double() == 123.0);

    // Out of range
    val_int.set_int(70000);
    v = Tuner.convert_from_int(val_int, VariantType.UINT16); // max 65535
    assert(v == null);

    // INT64 source
    var val_int64 = Value(Type.INT64);
    val_int64.set_int64(-1000);
    v = Tuner.convert_from_int(val_int64, VariantType.INT32);
    assert(v != null && v.get_int32() == -1000);
}

void test_convert_from_uint() {
    var val_uint = Value(Type.UINT);
    val_uint.set_uint(4000);

    var v = Tuner.convert_from_uint(val_uint, VariantType.INT16);
    assert(v != null && v.get_int16() == 4000);

    v = Tuner.convert_from_uint(val_uint, VariantType.UINT16);
    assert(v != null && v.get_uint16() == 4000);

    // Out of range
    val_uint.set_uint(70000);
    v = Tuner.convert_from_uint(val_uint, VariantType.UINT16);
    assert(v == null);

    // UINT64 source
    var val_uint64 = Value(Type.UINT64);
    val_uint64.set_uint64(18446744073709551615UL);
    v = Tuner.convert_from_uint(val_uint64, VariantType.UINT64);
    assert(v != null && v.get_uint64() == 18446744073709551615UL);
    v = Tuner.convert_from_uint(val_uint64, VariantType.UINT32);
    assert(v == null); // overflow
}

void test_convert_from_float() {
    var val_double = Value(Type.DOUBLE);
    val_double.set_double(123.456);

    var v = Tuner.convert_from_float(val_double, VariantType.INT32);
    assert(v != null && v.get_int32() == 123);

    v = Tuner.convert_from_float(val_double, VariantType.DOUBLE);
    assert(v != null && v.get_double() == 123.456);

    // Float source
    var val_float = Value(Type.FLOAT);
    val_float.set_float(123.456F);
    v = Tuner.convert_from_float(val_float, VariantType.INT32);
    assert(v != null && v.get_int32() == 123);
}

void test_convert_to_int() {
    Value val = Value(Type.INT);
    var v_int32 = new Variant.int32(42);
    assert(Tuner.convert_to_int(ref val, v_int32) == true);
    assert(val.get_int() == 42);

    val.unset();
    val.init(Type.INT);
    var v_int64_large = new Variant.int64(1125899906842624);
    assert(Tuner.convert_to_int(ref val, v_int64_large) == false);  // overflows int

    val.unset();
    val.init(Type.UINT);
    var v_int16 = new Variant.int16(-10);
    assert(Tuner.convert_to_int(ref val, v_int16) == false);
}

void test_convert_to_uint() {
    Value val = Value(Type.UINT);
    var v_uint32 = new Variant.uint32(12345);
    assert(Tuner.convert_to_uint(ref val, v_uint32) == true);
    assert(val.get_uint() == 12345);

    val.unset();
    val.init(Type.INT);
    var v_uint16 = new Variant.uint16(300);
    assert(Tuner.convert_to_uint(ref val, v_uint16) == true);
    assert(val.get_int() == 300);

    val.unset();
    val.init(Type.INT64);
    var v_uint64_large = new Variant.uint64(9223372036854775808);
    assert(Tuner.convert_to_uint(ref val, v_uint64_large) == false); // exceeds int64.MAX
}

void test_convert_to_float() {
    Value val = Value(Type.DOUBLE);
    var v_double = new Variant.double(9.81);
    assert(Tuner.convert_to_float(ref val, v_double) == true);
    assert(val.get_double() == 9.81);

    val.unset();
    val.init(Type.INT);
    v_double = new Variant.double(3.99);
    assert(Tuner.convert_to_float(ref val, v_double) == true);
    assert(val.get_int() == 3); // truncated
}

int main(string[] args) {
    Test.init(ref args);

    Test.add_func("/tuner/from_variant_type", test_from_variant_type);
    Test.add_func("/tuner/to_variant_type", test_to_variant_type);
    Test.add_func("/tuner/variant_to_double", test_variant_to_double);
    Test.add_func("/tuner/value_to_string", test_value_to_string);
    Test.add_func("/tuner/convert_from_value", test_convert_from_value);
    Test.add_func("/tuner/convert_to_value", test_convert_to_value);
    Test.add_func("/tuner/convert_from_int", test_convert_from_int);
    Test.add_func("/tuner/convert_from_uint", test_convert_from_uint);
    Test.add_func("/tuner/convert_from_float", test_convert_from_float);
    Test.add_func("/tuner/convert_to_int", test_convert_to_int);
    Test.add_func("/tuner/convert_to_uint", test_convert_to_uint);
    Test.add_func("/tuner/convert_to_float", test_convert_to_float);

    return Test.run();
}
