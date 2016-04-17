STACK_VERSION=	1.0.4.3
DISTNAME=	stack-dependencies-${STACK_VERSION}

${DISTNAME}.tar.gz:
	mkdir -p ${DISTNAME}
	env HOME=${DISTNAME} cabal update
	env HOME=${DISTNAME} cabal fetch stack==${STACK_VERSION}
	tar -cvf ${DISTNAME}.tar ${DISTNAME}
	gzip ${DISTNAME}.tar

clean:
	rm -rf ${DISTNAME} ${DISTNAME}.tar ${DISTNAME}.tar.gz

.PHONY:	clean
