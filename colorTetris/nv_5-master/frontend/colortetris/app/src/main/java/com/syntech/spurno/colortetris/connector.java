package com.syntech.spurno.colortetris;

import android.content.Context;
import android.widget.FrameLayout;
import android.widget.ImageView;

/**
 * Connector manages an imageview for the GUI of the game and indicates connected blocks with position.
 */
public class connector {

    /**
     * Indicates the position of a block connected by the connector and the posistion on the block
     * that this connector is at.
     * 0 - top left, 1 - top, 2 - top right, 3 - right, 4 - bottom right, 5 - bottom,
     * 6 - bottom left, 7 - left
     */
    private int position;
    /**
     * the coordinates of the connector
     */
    private int x, y;
    /**
     * the image of the connector
     */
    private ImageView image;

    /**
     * Generates a connector, images have yet to be implemented as I cannot get the background to
     * be transparent
     * @param pos the position of the connector
     * @param x the x coordinate of the connector
     * @param y the y coordinate of the connector
     * @param act the activity the connector is being made on
     * @param rel the framelayout the connector image is being drawn onto
     */
    public connector(int pos, int x, int y, Context act, FrameLayout rel) {
        this.position = pos;
        this.x = x;
        this.y = y;
    }

    /**
     * A simple getter method that returns the position of the connector not to be confused with coordinates
     * @return the position of the connector
     */
    public int getPosition() {
        return this.position;
    }

    /**
     * A simple setter method that changes the position of the connector
     * @param pos the new position of the connector
     */
    public void setPosition(int pos) {
        this.position = pos;
    }

    /**
     * A simple getter method that returns the x coordinate of the connector
     * @return the x coordinate of the connector
     */
    public int getX() {
        return this.x;
    }

    /**
     * A simple setter method that changes the x coordinate of the connector
     * @param x the new x coordinate of the connector
     */
    public void setX(int x) {
        this.x = x;
    }

    /**
     * A simple getter method that returns the y coordinate of the connector
     * @return the y coordinate of the connector
     */
    public float getY() {
        return this.y;
    }

    /**
     * A simple setter method that changes the y coordinate of the connector
     * @param y the new y coordinate of the connector
     */
    public void setY(int y) {
        this.y = y;
    }

    /**
     * Rotates the connector clockwise and changes its position
     * @param x the new x of the connector
     * @param y the new y of the connector
     * @param rel the framelayout the image needs to be updated on
     */
    public void rotateClockwise(int x, int y, FrameLayout rel) {
        this.x = x;
        this.y = y;
        position += 2;
        if (position > 7)
            position -= 8;
    }

    /**
     * Rotates the connector counterclockwise and changes its position
     * @param x the new x of the connector
     * @param y the new y of the connector
     * @param rel the framelayout the image needs to be updated on
     */
    public void rotateCounterClockwise(int x, int y, FrameLayout rel) {
        this.x = x;
        this.y = y;
        position -= 2;
        if (position < 0)
            position += 8;
    }

    /**
     * changes the x and y coordinate of the connector due to its block moving
     * @param x the new x of the block
     * @param y the new y of the block
     * @param rel the framelayout the image needs to be updated on
     */
    public void move(int x, int y, FrameLayout rel){
        this.x = x;
        this.y = y;
    }

    /**
     * Removes the image of the connector from the frame layout
     * @param rel the framelayout to remove the image from
     */
    public void delete(FrameLayout rel) {
    }
}

