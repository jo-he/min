import tables, strutils, os
import parser, interpreter, utils

minsym "exit":
  quit(0)

# Common stack operations

minsym "i":
  discard

minsym "pop":
  discard i.pop

minsym "dup":
  i.push i.peek

minsym "dip":
  let q = i.pop
  if not q.isQuotation:
    i.error errNoQuotation
  let v = i.pop
  for item in q.qVal:
    i.push item
  i.push v

minsym "swap":
  let a = i.pop
  let b = i.pop
  i.push a
  i.push b

# Operations on quotations

minsym "quote":
  let a = i.pop
  i.push TMinValue(kind: minQuotation, qVal: @[a])

minsym "unquote":
  let q = i.pop
  if not q.isQuotation:
    i.error errNoQuotation
  for item in q.qVal:
   i.push item 

minsym "cons":
  var q = i.pop
  let v = i.pop
  if not q.isQuotation:
    i.error errNoQuotation
  q.qVal.add v
  i.push q

minsym "map":
  let prog = i.pop
  let list = i.pop
  if prog.isQuotation and list.isQuotation:
    i.push newVal(newSeq[TMinValue](0))
    for litem in list.qVal:
      i.push litem
      for pitem in prog.qVal:
        i.push pitem
      i.apply("swap") 
      i.apply("cons") 
  else:
    i.error(errIncorrect, "Two quotations are required on the stack")

# Operations on the whole stack

minsym "dump":
  echo i.dump

# Operations on quotations or strings

minsym "concat":
  var q1 = i.pop
  var q2 = i.pop
  if q1.isString and q2.isString:
    let s = q2.strVal & q1.strVal
    i.push newVal(s)
  elif q1.isQuotation and q2.isQuotation:
    let q = q2.qVal & q1.qVal
    i.push newVal(q)
  else:
    i.error(errIncorrect, "Two quotations or two strings are required on the stack")

minsym "first":
  var q = i.pop
  if q.isQuotation:
    i.push q.qVal[0]
  elif q.isString:
    i.push newVal($q.strVal[0])
  else:
    i.error(errIncorrect, "A quotation or a string is required on the stack")

minsym "rest":
  var q = i.pop
  if q.isQuotation:
    i.push newVal(q.qVal[1..q.qVal.len-1])
  elif q.isString:
    i.push newVal(q.strVal[1..q.strVal.len-1])
  else:
    i.error(errIncorrect, "A quotation or a string is required on the stack")

# Arithmetic

minsym "+":
  let a = i.pop
  let b = i.pop
  if a.isInt:
    if b.isInt:
      i.push newVal(a.intVal + b.intVal)
    elif b.isFloat:
      i.push newVal(a.intVal.float + b.floatVal)
    else:
      i.error(errTwoNumbersRequired)
  elif a.isFloat:
    if b.isFloat:
      i.push newVal(a.floatVal + b.floatVal)
    elif b.isInt:
      i.push newVal(a.floatVal + b.intVal.float)
    else:
      i.error(errTwoNumbersRequired)

minsym "-":
  let a = i.pop
  let b = i.pop
  if a.isInt:
    if b.isInt:
      i.push newVal(b.intVal - a.intVal)
    elif b.isFloat:
      i.push newVal(b.floatVal - a.intVal.float)
    else:
      i.error(errTwoNumbersRequired)
  elif a.isFloat:
    if b.isFloat:
      i.push newVal(b.floatVal - a.floatVal)
    elif b.isInt:
      i.push newVal(b.intVal.float - a.floatVal) 
    else:
      i.error(errTwoNumbersRequired)

minsym "*":
  let a = i.pop
  let b = i.pop
  if a.isInt:
    if b.isInt:
      i.push newVal(a.intVal * b.intVal)
    elif b.isFloat:
      i.push newVal(a.intVal.float * b.floatVal)
    else:
      i.error(errTwoNumbersRequired)
  elif a.isFloat:
    if b.isFloat:
      i.push newVal(a.floatVal * b.floatVal)
    elif b.isInt:
      i.push newVal(a.floatVal * b.intVal.float)
    else:
      i.error(errTwoNumbersRequired)

minsym "/":
  let a = i.pop
  let b = i.pop
  if b.isInt and b.intVal == 0:
    i.error errDivisionByZero
  if a.isInt:
    if b.isInt:
      i.push newVal(b.intVal / a.intVal)
    elif b.isFloat:
      i.push newVal(b.floatVal / a.intVal.float)
    else:
      i.error(errTwoNumbersRequired)
  elif a.isFloat:
    if b.isFloat:
      i.push newVal(b.floatVal / a.floatVal)
    elif b.isInt:
      i.push newVal(b.intVal.float / a.floatVal) 
    else:
      i.error(errTwoNumbersRequired)

# Language constructs

minsym "def":
  let q1 = i.pop
  let q2 = i.pop
  if q1.isQuotation and q2.isQuotation:
    if q1.qVal.len == 1 and q1.qVal[0].kind == minSymbol:
      minsym q1.qVal[0].symVal:
        i.evaluating = true
        for item in q2.qVal:
          i.push item
        i.evaluating = false
    else:
      i.error(errIncorrect, "The top quotation must contain only one symbol value")
  else:
    i.error(errIncorrect, "Two quotations or two strings is required on the stack")

# Comparison operators

minsym ">":
  let n2 = i.pop
  let n1 = i.pop
  if n1.isNumber and n2.isNumber:
    if n1.isInt and n2.isInt:
      i.push newVal(n1.intVal > n2.intVal)
    elif n1.isInt and n2.isFloat:
      i.push newVal(n1.intVal.float > n2.floatVal)
    elif n1.isFloat and n2.isFloat:
      i.push newVal(n1.floatVal > n2.floatVal)
    elif n1.isFloat and n2.isInt:
      i.push newVal(n1.floatVal > n2.intVal.float)
  elif n1.isString and n2.isString:
      i.push newVal(n1.strVal > n2.strVal)
  else:
    i.error(errIncorrect, "Two numbers or two strings are required on the stack")

minsym ">=":
  let n2 = i.pop
  let n1 = i.pop
  if n1.isNumber and n2.isNumber:
    if n1.isInt and n2.isInt:
      i.push newVal(n1.intVal >= n2.intVal)
    elif n1.isInt and n2.isFloat:
      i.push newVal(n1.intVal.float >= n2.floatVal)
    elif n1.isFloat and n2.isFloat:
      i.push newVal(n1.floatVal >= n2.floatVal)
    elif n1.isFloat and n2.isInt:
      i.push newVal(n1.floatVal >= n2.intVal.float)
  elif n1.isString and n2.isString:
      i.push newVal(n1.strVal >= n2.strVal)
  else:
    i.error(errIncorrect, "Two numbers or two strings are required on the stack")

minsym "<":
  let n1 = i.pop
  let n2 = i.pop
  if n1.isNumber and n2.isNumber:
    if n1.isInt and n2.isInt:
      i.push newVal(n1.intVal > n2.intVal)
    elif n1.isInt and n2.isFloat:
      i.push newVal(n1.intVal.float > n2.floatVal)
    elif n1.isFloat and n2.isFloat:
      i.push newVal(n1.floatVal > n2.floatVal)
    elif n1.isFloat and n2.isInt:
      i.push newVal(n1.floatVal > n2.intVal.float)
  elif n1.isString and n2.isString:
      i.push newVal(n1.strVal > n2.strVal)
  else:
    i.error(errIncorrect, "Two numbers or two strings are required on the stack")

minsym "<=":
  let n1 = i.pop
  let n2 = i.pop
  if n1.isNumber and n2.isNumber:
    if n1.isInt and n2.isInt:
      i.push newVal(n1.intVal >= n2.intVal)
    elif n1.isInt and n2.isFloat:
      i.push newVal(n1.intVal.float >= n2.floatVal)
    elif n1.isFloat and n2.isFloat:
      i.push newVal(n1.floatVal >= n2.floatVal)
    elif n1.isFloat and n2.isInt:
      i.push newVal(n1.floatVal >= n2.intVal.float)
  elif n1.isString and n2.isString:
      i.push newVal(n1.strVal >= n2.strVal)
  else:
    i.error(errIncorrect, "Two numbers or two strings are required on the stack")

minsym "==":
  let n2 = i.pop
  let n1 = i.pop
  if (n1.kind == n2.kind or (n1.isNumber and n2.isNumber)) and not n1.isSymbol:
    i.push newVal(n1 == n2)
  else:
    i.error(errIncorrect, "Two non-symbol values of similar type are required")

minsym "!=":
  let n2 = i.pop
  let n1 = i.pop
  if (n1.kind == n2.kind or (n1.isNumber and n2.isNumber)) and not n1.isSymbol:
    i.push newVal(not (n1 == n2))
  else:
    i.error(errIncorrect, "Two non-symbol values of similar type are required")

# Boolean Logic

minsym "not":
  let b = i.pop
  if b.isBool:
    i.push newVal(not b.boolVal)
  else:
    i.error(errIncorrect, "A bool value is required on the stack")

minsym "and":
  let a = i.pop
  let b = i.pop
  if a.isBool and b.isBool:
    i.push newVal(a.boolVal and b.boolVal)
  else:
    i.error(errIncorrect, "Two bool values are required on the stack")

minsym "or":
  let a = i.pop
  let b = i.pop
  if a.isBool and b.isBool:
    i.push newVal(a.boolVal or b.boolVal)
  else:
    i.error(errIncorrect, "Two bool values are required on the stack")

minsym "xor":
  let a = i.pop
  let b = i.pop
  if a.isBool and b.isBool:
    i.push newVal(a.boolVal xor b.boolVal)
  else:
    i.error(errIncorrect, "Two bool values are required on the stack")

# I/O 

minsym "puts":
  let a = i.peek
  echo a

minsym "gets":
  i.push newVal(stdin.readLine())

minsym "print":
  let a = i.peek
  a.print

minsym "read":
  let a = i.pop
  if a.isString:
    if a.strVal.fileExists:
      try:
        i.push newVal(a.strVal.readFile)
      except:
        warn getCurrentExceptionMsg()
    else:
      warn "File '$1' not found" % [a.strVal]
  else:
    i.error(errIncorrect, "A string is required on the stack")

minsym "write":
  let a = i.pop
  let b = i.pop
  if a.isString and b.isString:
    try:
      a.strVal.writeFile(b.strVal)
    except:
      warn getCurrentExceptionMsg()
  else:
    i.error(errIncorrect, "Two strings are required on the stack")

# OS 

minsym "pwd":
  i.push newVal(getCurrentDir())

minsym "ls":
  let a = i.pop
  var list = newSeq[TMinValue](0)
  if a.isString:
    if a.strVal.existsDir:
      for i in walkdir(a.strVal):
        list.add newVal(i.path)
      i.push list.newVal
    else:
      warn "Directory '$1' not found" % [a.strVal]
  else:
    i.error(errIncorrect, "A string is required on the stack")


# Aliases

minalias "quit", "exit"
minalias "&", "concat"
minalias "%", "print"
minalias ":", "def"
minalias "eq", "=="
minalias "noteq", "!="
minalias "gt", ">"
minalias "lt", "<"
minalias "gte", ">="
minalias "lte", "<="
minalias "echi", "puts"
