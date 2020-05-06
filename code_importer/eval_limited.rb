ResourceLimits = Java.type("org.graalvm.polyglot.ResourceLimits")
Context = Java.type("org.graalvm.polyglot.Context")
ByteArrayOutputStream = Java.type("java.io.ByteArrayOutputStream")

def eval_limited(language, string)
  limits = ResourceLimits.newBuilder().statementLimit(20000, nil).build()
  context = Context.newBuilder([]).resourceLimits(limits).out(ByteArrayOutputStream.new()).build()
  begin
    context.eval(language, string)
  rescue => e
    e
  ensure
    context.close
  end
end

method(:eval_limited)
