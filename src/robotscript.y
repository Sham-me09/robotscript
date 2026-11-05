/* robotscript.y
 * Parser (Bison) for RobotScript DSL.
 * Validates grammar for move/turn/stop commands and drives the
 * virtual execution engine that tracks robot position and heading.
 */

%{
#include <stdio.h>
#include <stdlib.h>

int yylex(void);
void yyerror(const char *s);

/* ---- Virtual execution engine state ---- */
static int pos_x = 0, pos_y = 0;
static int heading = 0;      /* 0=NORTH, 90=EAST, 180=SOUTH, 270=WEST */
static int stopped = 0;
static int had_error = 0;
static int border_reached = 0;

/* Ground boundaries: X in [-100, 100], Y in [0, 100] */
#define X_MIN -100
#define X_MAX  100
#define Y_MIN  0
#define Y_MAX  100

static const char *dir_name(int h) {
    switch (h) {
        case 0:   return "NORTH";
        case 90:  return "EAST";
        case 180: return "SOUTH";
        case 270: return "WEST";
        default:  return "UNKNOWN";
    }
}

static void do_move(int is_forward, int dist) {
    int d = is_forward ? dist : -dist;
    int hit_border = 0;

    switch (heading) {
        case 0:   /* NORTH: +Y */
            pos_y += d;
            if (pos_y > Y_MAX) { pos_y = Y_MAX; hit_border = 1; }
            if (pos_y < Y_MIN) { pos_y = Y_MIN; hit_border = 1; }
            break;
        case 90:  /* EAST: +X */
            pos_x += d;
            if (pos_x > X_MAX) { pos_x = X_MAX; hit_border = 1; }
            if (pos_x < X_MIN) { pos_x = X_MIN; hit_border = 1; }
            break;
        case 180: /* SOUTH: -Y */
            pos_y -= d;
            if (pos_y > Y_MAX) { pos_y = Y_MAX; hit_border = 1; }
            if (pos_y < Y_MIN) { pos_y = Y_MIN; hit_border = 1; }
            break;
        case 270: /* WEST: -X */
            pos_x -= d;
            if (pos_x > X_MAX) { pos_x = X_MAX; hit_border = 1; }
            if (pos_x < X_MIN) { pos_x = X_MIN; hit_border = 1; }
            break;
    }

    if (hit_border) {
        border_reached = 1;
        heading = (heading + 180) % 360;   /* turn back at the border */
    }
}

/* Prints the final report and terminates the process immediately.
 * Called the instant STOP is parsed, so interactive terminal use
 * (typing commands line by line) doesn't need to wait for EOF. */
static void finish_and_exit(void) {
    stopped = 1;
    printf("Compilation Successful\n");
    printf("COMPUTED FINAL STATE:\n");
    printf("Final Position: (%d, %d)\n", pos_x, pos_y);
    printf("Final Direction: %s\n", dir_name(heading));
    printf("Machine Status: STOPPED\n");
    if (border_reached) {
        printf("Reached the border\n");
    }
    exit(0);
}

static void do_turn(int is_right, int angle) {
    if (is_right)
        heading = (heading + angle) % 360;
    else
        heading = ((heading - angle) % 360 + 360) % 360;
}
%}

%union {
    int num;
}

%token ROBOT MOVE TURN STOP FORWARD BACKWARD LEFT RIGHT
%token <num> NUMBER

%%

program:
      /* empty */
    | program statement
    ;

statement:
      ROBOT
    | MOVE FORWARD NUMBER   { do_move(1, $3); }
    | MOVE BACKWARD NUMBER  { do_move(0, $3); }
    | TURN RIGHT NUMBER     { do_turn(1, $3); }
    | TURN LEFT NUMBER      { do_turn(0, $3); }
    | STOP                  { finish_and_exit(); }
    ;

%%

void yyerror(const char *s) {
    had_error = 1;
    fprintf(stderr, "Syntax Error: %s\n", s);
}

int main(void) {
    printf("Initial State: Position = (0, 0), Direction = NORTH\n");

    yyparse();
    /* Reaching here means input ended (EOF) without an explicit "stop". */

    if (had_error) {
        printf("Compilation Failed\n");
        return 1;
    }

    printf("Compilation Successful\n");
    printf("COMPUTED FINAL STATE:\n");
    printf("Final Position: (%d, %d)\n", pos_x, pos_y);
    printf("Final Direction: %s\n", dir_name(heading));
    printf("Machine Status: RUNNING (no 'stop' command found)\n");
    if (border_reached) {
        printf("Reached the border\n");
    }

    return 0;
}
