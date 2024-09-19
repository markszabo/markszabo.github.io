---
layout: post
title: "Fuzzing with Bazel: cc_fuzz_test"
tags: tech security
---

Recently I have been fuzzing C/C++ projects built with Bazel using libfuzzer, so I thought to share my learnings on some of the details on how to do this.

<!--break-->

# Getting started

[Bazel added support for fuzz tests back in 2021](https://blog.bazel.build/2021/02/08/rules-fuzzing.html) via the [rules_fuzzing Bazel library](https://github.com/bazel-contrib/rules_fuzzing). I recommend starting with the [README of that repo](https://github.com/bazel-contrib/rules_fuzzing?tab=readme-ov-file#bazel-rules-for-fuzz-tests) then checking out [the other docs too](https://github.com/bazel-contrib/rules_fuzzing/tree/master/docs).

# Passing CLI flags

There are 3 types of CLI flags one can use when running a fuzz test:

* Bazel's usual flags (e.g. `--config=asan-libfuzzer`)
* the [fuzz test launcher flags](https://github.com/bazelbuild/rules_fuzzing/blob/master/docs/guide.md#the-fuzz-test-launcher) (e.g. `--timeout_secs=30`)
* the fuzzing-engine-specific flags (passed directly to the compiled library) (e.g. [in the case of libfuzzer](https://llvm.org/docs/LibFuzzer.html#options): `-max_len`)

These are separated by `--` when calling bazel, e.g.:

```shell
bazel run -c opt --config=asan-libfuzzer //examples:re2_fuzz_test_run \
  -- --clean --timeout_secs=30 \
  -- -max_len 256
```

To get all the supported flags for your specific tool versions, you can just ask the tools:

```shell
bazel run --config=asan-libfuzzer //examples:re2_fuzz_test_run -- --helpfull
```

and for the libfuzzer flags (mind the double `--` and that the flag starts with a single `-`):

```shell
bazel run --config=asan-libfuzzer //examples:re2_fuzz_test_run -- -- -help=1
```

# Corpus

Corpus, the set of initial inputs to pass to the test and then mutate them for additional coverage. Generally there are two types of corpus:

* **seed corpus**: a set of known inputs defined when writing a test to help show some valid (and potentially invalid) inputs to the fuzzing engine. E.g. if the function expects a json with some specific fields, you should pass that as a corpus, otherwise most of the fuzzing engine's time will be spent on trying to brute-force the json format and won't reach deeper into the code.
* **previously generated corpus**: when fuzzing stops, it will have a set of inputs that it found to execute different code-paths. Keeping these between fuzzing runs is the way to ensure that the fuzzing engine keeps its progress and doesn't have to start from zero each time.

In some cases you might have both of these corpora.

`rules_fuzzing` has 3 ways to pass the corpus to a libfuzzer test (the first two of these should be the same for other fuzzing engines too):

## 1. Define it in `cc_fuzz_test`

[As shown in the docs](https://github.com/bazel-contrib/rules_fuzzing/blob/master/docs/guide.md#specifying-seed-corpora):

```
cc_fuzz_test(
    name = "fuzz_test",
    srcs = ["fuzz_test.cc"],
    corpus = glob(["fuzz_test_corpus/**"]),
)
```

## 2. Via the` --corpus_dir` launcher option

This is not documented in the repository, but `-- --helpfull` shows it:

```
  --corpus_dir: If non-empty, a directory that will be used as a seed corpus for the fuzzer.
```

For example:

```shell
bazel run -c opt --config=asan-libfuzzer //examples:re2_fuzz_test_run \
  -- --corpus_dir="$(pwd)/corpus"
```

## 3. Via a libfuzzer argument

Libfuzzer accepts [corpus directories as positional arguments](https://llvm.org/docs/LibFuzzer.html#options):

> To run the fuzzer, pass zero or more corpus directories as command line arguments. The fuzzer will read test inputs from each of these corpus directories, and any new test inputs that are generated will be written back to the first corpus directory

For example:

```shell
bazel run -c opt --config=asan-libfuzzer //examples:re2_fuzz_test_run \
  -- \
  -- "$(pwd)/corpus"
```

## Multiple corpus definitions

What if more than one of the above 3 are defined? Do the corpora get merged, or do these options override each other?

Turns out the `--corpus_dir` parameter overrides the `corpus` defined in `cc_fuzz_test`, but the one passed to libfuzzer always gets appended.

One can check this by looking at the CLI log when running a test that defines `corpus`:

```shell
bazel run --config=asan-libfuzzer //examples:re2_fuzz_test_run --  -- $(pwd)/corpus2/
...
INFO: Loaded 1 PC tables (101 PCs): 101 [0x00dead,0x00beef), 
INFO:        0 files found in /tmp/fuzzing/corpus
INFO:        5 files found in examples/re2_fuzz_test_corpus
INFO:        1 files found in /home/ubuntu/fuzzing/test-app/corpus2/
INFO: -max_len is not provided; libFuzzer will not generate inputs larger than 4096 bytes
```

While if we run the same test but pass the `--corpus_dir`, then the corpus defined in `cc_fuzz_test` is not used:

```shell
bazel run --config=asan-libfuzzer //examples:re2_fuzz_test_run -- --corpus_dir=$(pwd)/corpus3 -- $(pw
d)/corpus2/
...
INFO: Loaded 1 PC tables (101 PCs): 101 [0x5aee48,0x5af498), 
INFO:        0 files found in /tmp/fuzzing/corpus
INFO:        2 files found in /home/ubuntu/fuzzing/test-app/corpus3
INFO:        1 files found in /home/ubuntu/fuzzing/test-app/corpus2/
INFO: -max_len is not provided; libFuzzer will not generate inputs larger than 4096 bytes
```
