package com.syntech.spurno.colortetris;

import android.content.Context;
import android.widget.FrameLayout;

import java.util.Random;

/**
 * gamePiece creates and manages groups of 3 blocks and is used to move them for the GUI and game.
 * Uses a builder pattern to randomly generate a large variety of different game piece design
 */
public class gamePiece {
    /**
     * The base starting X coordinate for b1
     */
    final int startingX = 6;
    /**
     * The base starting Y coordinate for b1
     */
    final int startingY = 19;
    /**
     * Central Block, has 2 connectors, connected to b2 through conn1 and b3 through conn3
     */
    private block b1;
    /**
     * Block connected to b1 through conn1, conn2 is null
     */
    private block b2;
    /**
     * Block connected to b1 through conn1, conn2 is null
     */
    private block b3;

    /**
     * Generates a new randomly generated gamePiece (up to 162 unique pieces)
     *
     * @param act the activity the piece is being generated to
     * @param rel the frameLayout that the images are being drawn to
     */
    public gamePiece(Context act, FrameLayout rel) {
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

    /**
     * remove the entire gamepiece, no real need for this currently, maybe for a preview system.
     *
     * @param rel the frameLayout the images are being removed from
     */
    public void delete(FrameLayout rel) {
        b1.delete(rel);
        b2.delete(rel);
        b3.delete(rel);
    }

    /**
     * Checks if the active piece can be shifted left and then shifts left if possible
     *
     * @param board the 2d array of blocks that helps determine if the block can shift left and then updates it.
     * @param rel   the frameLayout to alter the block and connector images locations
     */
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
        if (checkX <= 0) {
            return;
        } else if (board[checkY - 1][checkX - 1] != null) {
            return;
        }
        b1.shiftLeft(rel);
        b2.shiftLeft(rel);
        b3.shiftLeft(rel);
    }

    /**
     * Checks if the active piece can be shifted right and then shifts right if possible
     *
     * @param board the 2d array of blocks that helps determine if the block can shift left and then updates it.
     * @param rel   the frameLayout to alter the block and connector images locations
     */
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
     * Checks if the active piece can be shifted down and then shifts down if possible.
     *
     * @param board the 2d array of blocks that helps determine if the block can shift left and then updates it.
     * @param rel   the frameLayout to alter the block and connector images locations
     * @return returns 1 if the piece can shift down, 0 otherwise
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

    /**
     * Checks if the active piece can be rotated clockwise and then rotates clockwise if possible
     *
     * @param board the 2d array of blocks that helps determine if the block can shift left and then updates it.
     * @param rel   the frameLayout to alter the block and connector images locations
     */
    public void rotateClockwise(block[][] board, FrameLayout rel) {
        int B2newX, B2newY, B3newX, B3newY;
        switch (b2.getConn1().getPosition()) {
            case 4:
                if(b2.getX()+2 > 10)
                    return;
                if(board[b2.getY()-1][b2.getX()+1] != null)
                    return;
                B2newX = b2.getX()+2;
                B2newY = b2.getY();
                break;
            case 5:
                if(b2.getX()+1 > 10 || b2.getY()-1 < 1)
                    return;
                if(board[b2.getY()-2][b2.getX()] != null)
                    return;
                B2newX = b2.getX()+1;
                B2newY = b2.getY()-1;
                break;
            case 6:
                if(b2.getY()-2 < 1)
                    return;
                if(board[b2.getY()-3][b2.getX()-1] != null)
                    return;
                B2newX = b2.getX();
                B2newY = b2.getY()-2;
                break;
            case 7:
                if(b2.getX()-1 < 1 || b2.getY()-1 < 1)
                    return;
                if(board[b2.getY()-2][b2.getX()-2] != null)
                    return;
                B2newX = b2.getX()-1;
                B2newY = b2.getY()-1;
                break;
            case 0:
                if(b2.getX()-2 < 1)
                    return;
                if(board[b2.getY()-1][b2.getX()-3] != null)
                    return;
                B2newX = b2.getX()-2;
                B2newY = b2.getY();
                break;
            case 1:
                if(b2.getX()-1 < 1 || b2.getY()+1 > 20)
                    return;
                if(board[b2.getY()][b2.getX()-2] != null)
                    return;
                B2newX = b2.getX()-1;
                B2newY = b2.getY()+1;
                break;
            case 2:
                if(b2.getY()+2 > 20)
                    return;
                if(board[b2.getY()+1][b2.getX()-1] != null)
                    return;
                B2newX = b2.getX();
                B2newY = b2.getY()+2;
                break;
            case 3:
                if(b2.getX()+1 > 10 || b2.getY()+1 > 20)
                    return;
                if(board[b2.getY()][b2.getX()] != null)
                    return;
                B2newX = b2.getX()+1;
                B2newY = b2.getY()+1;
                break;
            default:
                return;
        }
        switch (b3.getConn1().getPosition()) {
            case 4:
                if(b3.getX()+2 > 10)
                    return;
                if(board[b3.getY()-1][b3.getX()+1] != null)
                    return;
                B3newX = b3.getX()+2;
                B3newY = b3.getY();
                break;
            case 5:
                if(b3.getX()+1 > 10 || b3.getY()-1 < 1)
                    return;
                if(board[b3.getY()-2][b3.getX()] != null)
                    return;
                B3newX = b3.getX()+1;
                B3newY = b3.getY()-1;
                break;
            case 6:
                if(b3.getY()-2 < 1)
                    return;
                if(board[b3.getY()-3][b3.getX()-1] != null)
                    return;
                B3newX = b3.getX();
                B3newY = b3.getY()-2;
                break;
            case 7:
                if(b3.getX()-1 < 1 || b3.getY()-1 < 1)
                    return;
                if(board[b3.getY()-2][b3.getX()-2] != null)
                    return;
                B3newX = b3.getX()-1;
                B3newY = b3.getY()-1;
                break;
            case 0:
                if(b3.getX()-2 < 1)
                    return;
                if(board[b3.getY()-1][b3.getX()-3] != null)
                    return;
                B3newX = b3.getX()-2;
                B3newY = b3.getY();
                break;
            case 1:
                if(b3.getX()-1 < 1 || b3.getY()+1 > 20)
                    return;
                if(board[b3.getY()][b3.getX()-2] != null)
                    return;
                B3newX = b3.getX()-1;
                B3newY = b3.getY()+1;
                break;
            case 2:
                if(b3.getY()+2 > 20)
                    return;
                if(board[b3.getY()+1][b3.getX()-1] != null)
                    return;
                B3newX = b3.getX();
                B3newY = b3.getY()+2;
                break;
            case 3:
                if(b3.getX()+1 > 10 || b3.getY()+1 > 20)
                    return;
                if(board[b3.getY()][b3.getX()] != null)
                    return;
                B3newX = b3.getX()+1;
                B3newY = b3.getY()+1;
                break;
            default:
                return;
        }
        b1.rotateClockwise(b1.getX(), b1.getY(), rel);
        b2.rotateClockwise(B2newX, B2newY, rel);
        b3.rotateClockwise(B3newX, B3newY, rel);
    }

    /**
     * Checks if the active piece can be rotated counterclockwise and then rotates counterclockwise if possible
     *
     * @param board the 2d array of blocks that helps determine if the block can shift left and then updates it.
     * @param rel   the frameLayout to alter the block and connector images locations
     */
    public void rotateCounterClockwise(block[][] board, FrameLayout rel) {
        int B2newX, B2newY, B3newX, B3newY;
        switch (b2.getConn1().getPosition()) {
            case 4:
                if(b2.getY()-2 < 1)
                    return;
                if(board[b2.getY()-3][b2.getX()-1] != null)
                    return;
                B2newX = b2.getX();
                B2newY = b2.getY()-2;
                break;
            case 5:
                if(b2.getX()-1 < 1 || b2.getY()-1 < 1)
                    return;
                if(board[b2.getY()-2][b2.getX()-2] != null)
                    return;
                B2newX = b2.getX()-1;
                B2newY = b2.getY()-1;
                break;
            case 6:
                if(b2.getX()-2 < 1)
                    return;
                if(board[b2.getY()-1][b2.getX()-3] != null)
                    return;
                B2newX = b2.getX()-2;
                B2newY = b2.getY();
                break;
            case 7:
                if(b2.getX()-1 < 1 || b2.getY()+1 > 20)
                    return;
                if(board[b2.getY()][b2.getX()-2] != null)
                    return;
                B2newX = b2.getX()-1;
                B2newY = b2.getY()+1;
                break;
            case 0:
                if(b2.getY()+2 > 20)
                    return;
                if(board[b2.getY()+1][b2.getX()-1] != null)
                    return;
                B2newX = b2.getX();
                B2newY = b2.getY()+2;
                break;
            case 1:
                if(b2.getX()+1 > 10 || b2.getY()+1 > 20)
                    return;
                if(board[b2.getY()][b2.getX()] != null)
                    return;
                B2newX = b2.getX()+1;
                B2newY = b2.getY()+1;
                break;
            case 2:
                if(b2.getX()+2 > 10)
                    return;
                if(board[b2.getY()-1][b2.getX()+1] != null)
                    return;
                B2newX = b2.getX()+2;
                B2newY = b2.getY();
                break;
            case 3:
                if(b2.getX()+1 > 10 || b2.getY()-1 < 1)
                    return;
                if(board[b2.getY()-2][b2.getX()] != null)
                    return;
                B2newX = b2.getX()+1;
                B2newY = b2.getY()-1;
                break;
            default:
                return;
        }
        switch (b3.getConn1().getPosition()) {
            case 4:
                if(b3.getY()-2 < 1)
                    return;
                if(board[b3.getY()-3][b3.getX()-1] != null)
                    return;
                B3newX = b3.getX();
                B3newY = b3.getY()-2;
                break;
            case 5:
                if(b3.getX()-1 < 1 || b3.getY()-1 < 1)
                    return;
                if(board[b3.getY()-2][b3.getX()-2] != null)
                    return;
                B3newX = b3.getX()-1;
                B3newY = b3.getY()-1;
                break;
            case 6:
                if(b3.getX()-2 < 1)
                    return;
                if(board[b3.getY()-1][b3.getX()-3] != null)
                    return;
                B3newX = b3.getX()-2;
                B3newY = b3.getY();
                break;
            case 7:
                if(b3.getX()-1 < 1 || b3.getY()+1 > 20)
                    return;
                if(board[b3.getY()][b3.getX()-2] != null)
                    return;
                B3newX = b3.getX()-1;
                B3newY = b3.getY()+1;
                break;
            case 0:
                if(b3.getY()+2 > 20)
                    return;
                if(board[b3.getY()+1][b3.getX()-1] != null)
                    return;
                B3newX = b3.getX();
                B3newY = b3.getY()+2;
                break;
            case 1:
                if(b3.getX()+1 > 10 || b3.getY()+1 > 20)
                    return;
                if(board[b3.getY()][b3.getX()] != null)
                    return;
                B3newX = b3.getX()+1;
                B3newY = b3.getY()+1;
                break;
            case 2:
                if(b3.getX()+2 > 10)
                    return;
                if(board[b3.getY()-1][b3.getX()+1] != null)
                    return;
                B3newX = b3.getX()+2;
                B3newY = b3.getY();
                break;
            case 3:
                if(b3.getX()+1 > 10 || b3.getY()-1 < 1)
                    return;
                if(board[b3.getY()-2][b3.getX()] != null)
                    return;
                B3newX = b3.getX()+1;
                B3newY = b3.getY()-1;
                break;
            default:
                return;
        }
        b1.rotateCounterClockwise(b1.getX(), b1.getY(), rel);
        b2.rotateCounterClockwise(B2newX, B2newY, rel);
        b3.rotateCounterClockwise(B3newX, B3newY, rel);
    }

    /**
     * FUNCTIONLESS, is used to potentially shift a piece from board to board if we want to implement a preview system
     *
     * @param board the new board for the piece.
     */
    public void toBoard(block[][] board) {
        board[b1.getY() - 1][b1.getX() - 1] = b1;
        board[b2.getY() - 1][b2.getX() - 1] = b2;
        board[b3.getY() - 1][b3.getX() - 1] = b3;
    }

    public boolean hasLost(block[][] board){
        if(board[b1.getY()-1][b1.getX()-1] != null){
            return true;
        }
        if(board[b2.getY()-1][b2.getX()-1] != null){
            return true;
        }
        if(board[b3.getY()-1][b3.getX()-1] != null){
            return true;
        }
        return false;
    }

    /**
     *
     */
    public void removeConnectors(){
        b1.delConn1();
        b1.delConn2();
        b2.delConn1();
        b2.delConn2();
        b3.delConn1();
        b3.delConn2();
    }
}

