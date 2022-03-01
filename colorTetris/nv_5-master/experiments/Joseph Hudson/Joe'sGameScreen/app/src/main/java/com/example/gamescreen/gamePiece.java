package com.example.gamescreen;

import android.content.Context;
import android.widget.FrameLayout;

import java.util.Random;

public class gamePiece {
    final int startingX = 6;
    final int startingY = 19;
    private block b1;//Central Block, has 2 connectors
    private block b2;//block connected to block 1 via conn 1
    private block b3;//block connected to block 1 via conn 2
    private Context act;

    public gamePiece(Context act, FrameLayout rel) {
        this.act = act;
        Random r = new Random();
        int pieceType = r.nextInt(6);//produces a random number from 0 to 5
        int color1, color2, color3;
        color1 = r.nextInt(3) + 1;//produces a number 1 to 3
        color2 = r.nextInt(3) + 1;//produces a number 1 to 3
        color3 = r.nextInt(3) + 1;//produces a number 1 to 3
        switch (pieceType) {
            case 0:
                b1 = new block(startingX, startingY, color1, 7, 3, act, rel);
                b2 = new block(startingX - 1, startingY, color2, 3, act, rel);
                b3 = new block(startingX + 1, startingY, color3, 7, act, rel);
                break;
            case 1:
                b1 = new block(startingX, startingY, color1, 1, 3, act, rel);
                b2 = new block(startingX, startingY + 1, color2, 5, act, rel);
                b3 = new block(startingX + 1, startingY, color3, 7, act, rel);
                break;
            case 2:
                b1 = new block(startingX, startingY, color1, 0, 4, act, rel);
                b2 = new block(startingX - 1, startingY + 1, color2, 4, act, rel);
                b3 = new block(startingX + 1, startingY - 1, color3, 0, act, rel);
                break;
            case 3:
                b1 = new block(startingX, startingY, color1, 0, 3, act, rel);
                b2 = new block(startingX - 1, startingY + 1, color2, 4, act, rel);
                b3 = new block(startingX + 1, startingY, color3, 7, act, rel);
                break;
            case 4:
                b1 = new block(startingX, startingY, color1, 0, 2, act, rel);
                b2 = new block(startingX - 1, startingY + 1, color2, 4, act, rel);
                b3 = new block(startingX + 1, startingY + 1, color3, 6, act, rel);
                break;
            case 5:
                b1 = new block(startingX, startingY, color1, 2, 7, act, rel);
                b2 = new block(startingX + 1, startingY + 1, color2, 6, act, rel);
                b3 = new block(startingX - 1, startingY, color3, 3, act, rel);
                break;
            default:
                break;
        }
    }

    public void delete(FrameLayout rel) {
        b1.delete(rel);
        b2.delete(rel);
        b3.delete(rel);
    }

    public void shiftLeft(block[][] board, FrameLayout rel) {
        int checkX, checkY;
        checkX = b1.getX() - 1;
        checkY = b1.getY();
        if (checkX <= 0) {
            return;
        } else if (board[checkY - 1][checkX - 1] != null) {
            return;
        }
        checkX = b2.getX() - 1;
        checkY = b2.getY();
        if (checkX <= 0) {
            return;
        } else if (board[checkY - 1][checkX - 1] != null) {
            return;
        }
        checkX = b3.getX() - 1;
        checkY = b3.getY();
        if (checkX <=0) {
            return;
        } else if (board[checkY - 1][checkX - 1] != null) {
            return;
        }
        b1.shiftLeft(rel);
        b2.shiftLeft(rel);
        b3.shiftLeft(rel);
    }

    public void shiftRight(block[][] board, FrameLayout rel) {
        int checkX, checkY;
        checkX = b1.getX() + 1;
        checkY = b1.getY();
        if (checkX == 11) {
            return;
        } else if (board[checkY - 1][checkX - 1] != null) {
            return;
        }
        checkX = b2.getX() + 1;
        checkY = b2.getY();
        if (checkX == 11) {
            return;
        } else if (board[checkY - 1][checkX - 1] != null) {
            return;
        }
        checkX = b3.getX() + 1;
        checkY = b3.getY();
        if (checkX == 11) {
            return;
        } else if (board[checkY - 1][checkX - 1] != null) {
            return;
        }
        b1.shiftRight(rel);
        b2.shiftRight(rel);
        b3.shiftRight(rel);
    }


    /**
     * @param board
     * @param rel
     * @return 0 if it cannot shift down, otherwise return 1
     */
    public int shiftDown(block[][] board, FrameLayout rel) {
        int checkX, checkY;
        checkX = b1.getX();
        checkY = b1.getY() - 1;
        if (checkY <= 0) {
            return 0;
        } else if (board[checkY - 1][checkX - 1] != null) {
            return 0;
        }
        checkX = b2.getX();
        checkY = b2.getY() - 1;
        if (checkY <= 0) {
            return 0;
        } else if (board[checkY - 1][checkX - 1] != null) {
            return 0;
        }
        checkX = b3.getX();
        checkY = b3.getY() - 1;
        if (checkY <= 0) {
            return 0;
        } else if (board[checkY - 1][checkX - 1] != null) {
            return 0;
        }
        b1.shiftDown(rel);
        b2.shiftDown(rel);
        b3.shiftDown(rel);
        return 1;
    }

    public void rotateClockwise(block[][] board, FrameLayout rel) {
        //TODO too many cases to get done in time
    }

    public void rotateCounterClockwise(block[][] board, FrameLayout rel) {
        //TODO too many cases to get done in time
    }

    public void toBoard(block[][] board) {
        board[b1.getY() - 1][b1.getX() - 1] = b1;
        board[b2.getY() - 1][b2.getX() - 1] = b2;
        board[b3.getY() - 1][b3.getX() - 1] = b3;
    }
}

