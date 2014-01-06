.SUFFIXES: .erl .beam

.erl.beam:
	erlc -W $<

MODS = regfun ringb

all: compile

compile: ${MODS:%=%.beam}

clean:
	rm -rf *.beam erl_crash.dump

