/*
 * The MIT License (MIT)
 * Copyright (c) 2020 Leif Lindbäck
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction,including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so,subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

package controller;

import java.util.List;
import integration.SoundgoodDAO;
import integration.SoundgoodDBException;
import model.InstrumentDTO;
import model.InstrumentException;

/**
 * This is the application's only controller, all calls to the model pass here.
 * The controller is also responsible for calling the DAO. Typically, the
 * controller first calls the DAO to retrieve data (if needed), then operates on
 * the data, and finally tells the DAO to store the updated data (if any).
 */
public class Controller {
    private final SoundgoodDAO soundgoodDB;

    /**
     * Creates a new instance, and retrieves a connection to the database.
     * @throws SoundgoodDBException If unable to connect to the database.
     */
    public Controller() throws SoundgoodDBException {
        soundgoodDB = new SoundgoodDAO();
    }

    /**
     * Creates a new rental for the specified instrument and student ID.
     * @param student_id The student ID.
     * @param instrument_id The instrument ID.
     * @throws InstrumentException If unable to rent instrument.
     */
    public void createRental(Integer student_id, Integer instrument_id) throws InstrumentException {
        String failureMsg = "Could not create rental for student_id: " + student_id + " and instrument: " + instrument_id + ".";

        if (student_id == null || instrument_id == null) {
            throw new InstrumentException(failureMsg);
        }

        List<? extends InstrumentDTO> instruments = getAllInstruments(true); //instruments get locked
        if (instruments.stream().noneMatch(o -> o.getInstrumentID().equals(instrument_id))) {
            throw new InstrumentException(failureMsg);
        }

        List<Integer> students;

        try {
            soundgoodDB.createRental(student_id, instrument_id);
            System.out.println("Sucessfully rented instrument " + instrument_id + " to student: " + student_id + ".");
        } catch (Exception e) {
            throw new InstrumentException(failureMsg, e);
        }
    }

       /**
     * Terminates rental with the specified rental ID.
     * 
     * @param rental_id The ID of the rental that shall be terminated.
     * @throws InstrumentException If failed to terminate the specified rental.
     */
    public void terminateRental(Integer rental_id) throws InstrumentException {
        String failureMsg = "Could not terminate rental: " + rental_id;

        if (rental_id == null) {
            throw new InstrumentException(failureMsg);
        }

        try {
            soundgoodDB.deleteRental(rental_id);
            System.out.println("Sucessfully terminated rental " + rental_id + ".");
        } catch (Exception e) {
            throw new InstrumentException(failureMsg, e);
        }
    }

    /**
     * Lists all available instruments in the whole school.
     * 
     * @return A list containing all available instruments. The list 
     *         is empty if there are no available instruments.
     * @throws InstrumentException If unable to retrieve instruments.
     */
    public List<? extends InstrumentDTO> getAllInstruments(boolean lockExclusive) throws InstrumentException {
        try {
            return soundgoodDB.readInstruments(lockExclusive);
        } catch (Exception e) {
            throw new InstrumentException("Unable to retrieve instruments.", e);
        }
    }
}
