(declare-project
  :name "meetup-generator"
  :description ```Stupid random string thing ```
  :version "0.0.0"
  :dependencies [
    { :url "https://github.com/joy-framework/joy" }
    { :url "https://github.com/janet-lang/spork" }
    { :url "https://github.com/ianthehenry/judge.git" }]
  :author "Rob Fisher"
  :license "BSD 2-Clause"
  :url ""
  :repo "")

(phony "server" []
  (os/shell "janet main.janet"))

(declare-executable
  :name "app"
  :entry "main.janet")
