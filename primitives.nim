import tables, strutils
import parser, interpreter, utils

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

minsym "print":
  let a = i.peek
  a.print
  echo ""

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

# Operations on the whole stack

minsym "dump":
  echo i.dump

# Operations on quotations or strings

minsym "concat":
  var q1 = i.pop
  var q2 = i.pop
  if q1.isString and q2.isString:
    let s = q2.strVal & q1.strVal
    i.push newString(s)
  elif q1.isQuotation and q2.isQuotation:
    let q = q2.qVal & q1.qVal
    i.push newQuotation(q)
  else:
    i.error(errIncorrect, "Two quotations or two strings is required on the stack")

minsym "first":
  var q = i.pop
  if q.isQuotation:
    i.push q.qVal[0]
  elif q.isString:
    i.push newString($q.strVal[0])
  else:
    i.error(errIncorrect, "A quotation or a string is required on the stack")

minsym "rest":
  var q = i.pop
  if q.isQuotation:
    i.push newQuotation(q.qVal[1..q.qVal.len-1])
  elif q.isString:
    i.push newString(q.strVal[1..q.strVal.len-1])
  else:
    i.error(errIncorrect, "A quotation or a string is required on the stack")

# Arithmetic

minsym "+":
  let a = i.pop
  let b = i.pop
  if a.isInt:
    if b.isInt:
      i.push newInt(a.intVal + b.intVal)
    elif b.isFloat:
      i.push newFloat(a.intVal.float + b.floatVal)
    else:
      i.error(errTwoNumbersRequired)
  elif a.isFloat:
    if b.isFloat:
      i.push newFloat(a.floatVal + b.floatVal)
    elif b.isInt:
      i.push newFloat(a.floatVal + b.intVal.float)
    else:
      i.error(errTwoNumbersRequired)

minsym "-":
  let a = i.pop
  let b = i.pop
  if a.isInt:
    if b.isInt:
      i.push newInt(b.intVal - a.intVal)
    elif b.isFloat:
      i.push newFloat(b.floatVal - a.intVal.float)
    else:
      i.error(errTwoNumbersRequired)
  elif a.isFloat:
    if b.isFloat:
      i.push newFloat(b.floatVal - a.floatVal)
    elif b.isInt:
      i.push newFloat(b.intVal.float - a.floatVal) 
    else:
      i.error(errTwoNumbersRequired)

minsym "*":
  let a = i.pop
  let b = i.pop
  if a.isInt:
    if b.isInt:
      i.push newInt(a.intVal * b.intVal)
    elif b.isFloat:
      i.push newFloat(a.intVal.float * b.floatVal)
    else:
      i.error(errTwoNumbersRequired)
  elif a.isFloat:
    if b.isFloat:
      i.push newFloat(a.floatVal * b.floatVal)
    elif b.isInt:
      i.push newFloat(a.floatVal * b.intVal.float)
    else:
      i.error(errTwoNumbersRequired)

minsym "/":
  let a = i.pop
  let b = i.pop
  if b.isInt and b.intVal == 0:
    i.error errDivisionByZero
  if a.isInt:
    if b.isInt:
      i.push newFloat(b.intVal / a.intVal)
    elif b.isFloat:
      i.push newFloat(b.floatVal / a.intVal.float)
    else:
      i.error(errTwoNumbersRequired)
  elif a.isFloat:
    if b.isFloat:
      i.push newFloat(b.floatVal / a.floatVal)
    elif b.isInt:
      i.push newFloat(b.intVal.float / a.floatVal) 
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

minalias "&", "concat"
minalias "%", "print"
minalias ":", "def"
