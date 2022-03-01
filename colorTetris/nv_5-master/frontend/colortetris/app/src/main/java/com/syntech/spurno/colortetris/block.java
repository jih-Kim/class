package com.syntech.spurno.colortetris;

import android.content.Context;
import android.widget.FrameLayout;
import android.widget.ImageView;

/**
 * Block is a helper class that manages 1 or 2 connectors and an imageview for the GUI.
 * Block also stores the integer that indicates the color of the block which is important for the
 * game functionality.
 */
public class block {

    /**
     * Connectors that indicate which direction a connected block is.
     */
    private connector conn1, conn2;
    /**
     * The coordinates of the block on the board
     */
    private int x, y;
    /**
     * indicates color of block and which image to use. 1 red, 2 blue, 3 yellow.
     */
    private int color;
    /**
     * The image of the block
     */
    private ImageView image;

    /**
     * Used to generate the central block in a gamepiece.
     * @param x the assigned x value of the new block
     * @param y the assigned y value of the new block
     * @param color the assigned color of the block
     * @param posConn1 position of connector 1 to be generated
     * @param posConn2 position of connector 2 to be generated
     * @param act the act the block is being made in
     * @param rel the frameLayout the image of the new block needs to be made in
     */
    public block(int x, int y, int color, int posConn1, int posConn2, Context act, FrameLayout rel) {
        this.x = x;
        this.y = y;
        this.color = color;
        conn1 = conn2 = null;
        image = new ImageView(act);

        switch (color) {
            case 1:
                image.setImageResource(R.drawable.redblock);
                break;
            case 2:
                image.setImageResource(R.drawable.blueblock);
                break;
            case 3:
                image.setImageResource(R.drawable.yellowblock);
                break;
            default:
                break;
        }
        rel.addView(image, rel.getWidth()/10+2, rel.getHeight()/20+2);
        updatePos(rel);
        this.conn1 = new connector(posConn1, x, y, act, rel);
        this.conn2 = new connector(posConn2, x, y, act, rel);
    }

    /**
     * Used to generate the noncentral blocks in a gamepiece.
     * @param x the assigned x value of the new block
     * @param y the assigned y value of the new block
     * @param color the assigned color of the block
     * @param posConn1 position of connector 1 to be generated
     * @param act the act the block is being made in
     * @param rel the frameLayout the image of the new block needs to be made in
     */
    public block(int x, int y, int color, int posConn1, Context act, FrameLayout rel) {
        this.x = x;
        this.y = y;
        this.color = color;
        this.image = new ImageView(act);
        switch (color) {
            case 1:
                image.setImageResource(R.drawable.redblock);
                break;
            case 2:
                image.setImageResource(R.drawable.blueblock);
                break;
            case 3:
                image.setImageResource(R.drawable.yellowblock);
                break;
            default:
                break;
        }
        rel.addView(image, rel.getWidth()/10+2, rel.getHeight()/20+2);
        updatePos(rel);
        this.conn1 = new connector(posConn1, x, y, act, rel);
        this.conn2 = null;
    }

    /**
     * updates the position of the image in the framelayout based on any shifts.
     * @param rel
     */
    public void updatePos(FrameLayout rel){
        image.setX(rel.getX()+14+((x-6)*rel.getWidth()/10));
        image.setY(rel.getY()-66+((18-y)*rel.getHeight()/20));
    }

    /**
     * a simple getter method that returns conn1
     * @return conn1
     */
    public connector getConn1() {
        return this.conn1;
    }

    /**
     * sets conn1 to null and removes its image
     */
    public void delConn1() {
        if (this.conn1 != null) {
            this.conn1 = null;
        }
    }

    /**
     * a simple getter method that returns conn2
     * @return conn2
     */
    public connector getConn2() {
        return this.conn2;
    }

    /**
     * sets conn2 to null and removes its image
     */
    public void delConn2() {
        if (this.conn2 != null) {
            this.conn2 = null;
        }
    }

    /**
     * A simple getter method that returns the block's color
     * @return the block's color
     */
    public int getColor() {
        return this.color;
    }

    /**
     * A simple setter method that changes the block's color, currently no use for it
     * @param color the int for the new color
     */
    public void setColor(int color) {
        if (color <= 4 && color > 0)
            this.color = color;
    }

    /**
     * A simple getter method that returns the block's x coordinate
     * @return the block's x coordinate
     */
    public int getX() {
        return this.x;
    }

    /**
     * A simple setter method that changes the block's x coordinate
     * @param x the block's new x coordinate
     */
    public void setX(int x) {
        this.x = x;
    }

    /**
     * A simple getter method that returns the block's y coordinate
     * @return the block's y coordinate
     */
    public int getY() {
        return this.y;
    }

    /**
     * A simple setter method that changes the block's y coordinate
     * @param y the block's new y coordinate
     */
    public void setY(int y) {
        this.y = y;
    }

    /**
     * Removes a block from the frameLayout and then delete's its connector(s)
     * @param rel the frameLayout the image is being removed from
     */
    public void delete(FrameLayout rel) {
        if(conn1 != null) {
            conn1.delete(rel);
            conn1 = null;
        }
        if(conn2 != null) {
            conn2.delete(rel);
            conn2 = null;
        }
        rel.removeView(image);
    }

    /**
     * Shifts the block left, and then updates its image on the board
     * @param rel the frameLayout the image needs to be updated in
     */
    public void shiftLeft(FrameLayout rel){
        this.x--;
        if(conn1 != null)
            conn1.move(this.x, this.y, rel);
        if(conn2 != null)
            conn2.move(this.x, this.y, rel);
        updatePos(rel);
    }

    /**
     * Shifts the block right, and then updates its image on the board
     * @param rel the frameLayout the image needs to be updated in
     */
    public void shiftRight(FrameLayout rel){
        this.x++;
        if(conn1 != null)
            conn1.move(this.x, this.y, rel);
        if(conn2 != null)
            conn2.move(this.x, this.y, rel);
        updatePos(rel);
    }

    /**
     * Shifts the block down, and then updates its image on the board
     * @param rel the frameLayout the image needs to be updated in
     */
    public void shiftDown(FrameLayout rel){
        this.y--;
        if(conn1 != null)
            conn1.move(this.x, this.y, rel);
        if(conn2 != null)
            conn2.move(this.x, this.y, rel);
        updatePos(rel);
    }

    /**
     * Rotates the block clockwise, and then updates its connector image(s) on the board
     * @param rel the frameLayout the image needs to be updated in
     * @param x the new x for the block
     * @param y the new y for the block
     */
    public void rotateClockwise(int x, int y, FrameLayout rel){
        this.x = x;
        this.y = y;
        if(conn1 != null)
            conn1.rotateClockwise(this.x, this.y, rel);
        if(conn2 != null)
            conn2.rotateClockwise(this.x, this.y, rel);
        updatePos(rel);
    }

    /**
     * Rotates the block counterclockwise, and then updates its connector image(s) on the board
     * @param rel the frameLayout the image needs to be updated in
     * @param x the new x for the block
     * @param y the new y for the block
     */
    public void rotateCounterClockwise(int x, int y, FrameLayout rel){
        this.x = x;
        this.y = y;
        if(conn1 != null)
            conn1.rotateCounterClockwise(this.x, this.y, rel);
        if(conn2 != null)
            conn2.rotateCounterClockwise(this.x, this.y, rel);
        updatePos(rel);
    }
}
