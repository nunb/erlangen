;;;; port-mapper: Standalone port mapper daemon.

(require :asdf)

(asdf:load-system :erlangen)

(defun port-mapper ()
  (when (intersection *command-line-argument-list*
                      '("-h" "-help" "--help")
                      :test 'string=)
    (princ "Usage: erlangen-port-mapper [host]
       erlangen-port-mapper -h|-help|--help")
    (quit 0))
  (destructuring-bind (exe &optional host)
      *command-line-argument-list*
    (declare (ignore exe))
    (apply 'erlangen.distribution.protocol.port-mapper:port-mapper
           (when host
             `(:directory-host ,host)))))

(defclass erlangen-port-mapper (ccl::application)
  ((command-line-arguments :initform nil)))

(setf ccl::*invoke-debugger-hook-on-interrupt* t)
(setf ccl::*debugger-hook*
      (lambda (condition hook)
        (declare (ignore hook))
        (etypecase condition
          (ccl::interrupt-signal-condition (quit 130)))))

(gc)

(save-application
 "bin/erlangen-port-mapper"
 :application-class 'erlangen-port-mapper
 :toplevel-function 'port-mapper
 :error-handler :quit
 :purify t
 :prepend-kernel t)
