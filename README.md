# meetup-generator-janet

Requires Janet 1.35.2-ish and `jpm`.

Get the dependencies. You might need to do something like

```
export JANET_TREE=${HOME}/.local/jpm_tree
```

in your `.profile` or whatever you have. Otherwise you'll need elevated 
privileges.

```
$ jpm deps
```

Run tests:

```
$ judge
```

Start a local instance:

```
$ jpm exec joy server
```
