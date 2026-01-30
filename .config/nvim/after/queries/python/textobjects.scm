; extends

; Module docstring
(module
  .
  (expression_statement (string) @comment.docs))

; Class docstring
(class_definition
  body: (block
          .
          (expression_statement (string) @comment.docs)))

; Function docstring
(function_definition
  body: (block
          .
          (expression_statement (string) @comment.docs)))
