
CC=gcc
CFLAGS=-Wall
LDFLAGS=-Wall -lfl
EXEC=tpcas
EXECBISON=tpcas
EXECFLEX=tpcas
SRC=src/
BIN=bin/
OBJ=obj/


$(BIN)$(EXEC): $(OBJ)tree.o $(OBJ)$(EXECBISON).tab.o $(OBJ)lex.yy.o
	$(CC) -o $@ $^ $(LDFLAGS)

$(SRC)lex.yy.c: $(SRC)$(EXECFLEX).lex
	flex -o $@ $<

$(SRC)$(EXECBISON).tab.c: $(SRC)$(EXECBISON).y
	bison -o $@ -d $<

$(OBJ)tree.o: $(SRC)tree.c $(SRC)tree.h

$(OBJ)%.o: $(SRC)%.c
	$(CC) -o $@ -c $< $(CFLAGS)

clean:
	rm -f $(SRC)lex.yy.c $(SRC)$(EXECBISON).tab.* $(BIN)$(EXEC) $(OBJ)*