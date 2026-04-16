#include <stdio.h>

struct Node {
    int val;
    struct Node* left;
    struct Node* right;
};

extern struct Node* insert(struct Node*, int);
extern int getAtMost(int, struct Node*);

int main() {
    struct Node* root = NULL;

    root = insert(root, 10);
    root = insert(root, 5);
    root = insert(root, 15);

    printf("%d\n", getAtMost(12, root));  // expected: 10

    return 0;
}
