CAT?=	cat
CP?=	cp
ECHO?=	echo
FALSE?=	false
GZIP?=	gzip
MKDIR?=	mkdir -p
RM?=	rm
SED?=	sed
TAR?=	tar
INSTALL_PROGRAM?=	install -s -m 555
INSTALL_DATA?=	install -m 0644
PREFIX?=	/usr/local
TARGET?=	${PWD}/${DISTNAME}
SETENV?=	env

STACK_VERSION=	1.0.4.3
DISTNAME=	stack-dependencies-${STACK_VERSION}

all: stack _stack.bash _stack.zsh

stack:
	@[ -d ${TARGET}/.cabal ] || ${FALSE}
# Make sure we use absolute paths in the cabal config file
	${SED} -i "" -e 's|${DISTNAME}/|${TARGET}/|g' ${TARGET}/.cabal/config
	${SETENV} HOME="${TARGET}" cabal install stack==${STACK_VERSION}
	${CP} ${TARGET}/.cabal/bin/stack stack

_stack.bash: stack
# Generate bash completion script
	./stack --bash-completion-script ${PREFIX}/bin/stack > ${@}

_stack.zsh: _stack.bash
# zsh completion reuses bash completion file via zsh's bashcompinit function
	${ECHO} "#compdef stack" > ${@}
	${ECHO} "autoload -U +X bashcompinit && bashcompinit" >> ${@}
	${CAT} ${>} >> ${@}

install: all
	${INSTALL_PROGRAM} stack ${PREFIX}/bin
	${MKDIR} ${PREFIX}/etc/bash_completion.d
	${INSTALL_DATA} _stack.bash ${PREFIX}/etc/bash_completion.d/_stack.bash
	${MKDIR} ${STAGEDIR}/share/zsh/site-functions/_stack
	${INSTALL_DATA} _stack.zsh ${PREFIX}/share/zsh/site-functions/_stack

${DISTNAME}.tar.gz:
	${MKDIR} -p ${DISTNAME}
	${SETENV} HOME=${DISTNAME} cabal update
	${SETENV} HOME=${DISTNAME} cabal fetch stack==${STACK_VERSION}
	${TAR} -cvf ${DISTNAME}.tar ${DISTNAME}
	${GZIP} ${DISTNAME}.tar

clean:
	${RM} -rf ${DISTNAME} ${DISTNAME}.tar ${DISTNAME}.tar.gz \
		_stack.zsh _stack.bash stack

.PHONY:	clean
