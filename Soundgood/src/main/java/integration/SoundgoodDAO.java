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

package integration;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import model.Instrument;

/**
 * This data access object (DAO) encapsulates all database calls in the bank
 * application. No code outside this class shall have any knowledge about the
 * database.
 */
public class SoundgoodDAO {
    private static final String INSTRUMENT_TABLE_NAME = "Instrument";
    private static final String INSTRUMENT_PK_COLUMN_NAME = "InstrumentID";
    private static final String INSTRUMENT_NAME_COLUMN_NAME = "Name";
    private static final String INSTRUMENT_TYPE_COLUMN_NAME = "Type";
    private static final String INSTRUMENT_BRAND_COLUMN_NAME = "Brand";
    private static final String INSTRUMENT_QUANTITY_COLUMN_NAME = "Quantity";

    private static final String RENTAL_TABLE_NAME = "StudentRentals";
    private static final String RENTAL_PK_COLUMN_NAME = "RentalID";
    private static final String RENTAL_TIME_COLUMN_NAME = "RentalStartDate";
    private static final String RENTAL_TERMINATED_COLUMN_NAME = "RentalEndDate";
    private static final String RENTAL_FK_STUDENT_COLUMN_NAME = "StudentID";
    private static final String RENTAL_FK_INSTRUMENT_COLUMN_NAME = "InstrumentID";

    private static final String RENTAL_PRICING_TABLE_NAME = "RentalPricing";
    private static final String RENTAL_PRICING_PK_COLUMN_NAME = "RentalPricingID";
    private static final String RENTAL_PRICING_PRICE_COLUMN_NAME = "Amount";
    private Connection connection;
    private PreparedStatement createRentalStatement;
    private PreparedStatement deleteRentalStatement;
    private PreparedStatement listInstrumentsStatement;
    private PreparedStatement listInstrumentsLockForUpdateStatement;
    private PreparedStatement createRentalPricingStatement;


    /**
     * Constructs a new DAO object connected to the soundgood database.
     */
    public SoundgoodDAO() throws SoundgoodDBException {
        try {
            connectToSoundgoodDB();
            prepareStatements();
        } catch (ClassNotFoundException | SQLException exception) {
            throw new SoundgoodDBException("Could not connect to datasource.", exception);
        }
    }

/**
     * Creates a new rental.

     * @param student_id The student renting the instrument.
     * @param instrument_id The instrument to rent.
     * @throws SoundgoodDBException If failed to create rental.
     */
public void createRental(Integer student_id, Integer instrument_id) throws SoundgoodDBException, SQLException {
    String failureMsg = "Could not create rental for student_id: " + student_id + " and instrument: " + instrument_id + ".";
    try {
        // Get the current date
        java.util.Date today = new java.util.Date();
        java.sql.Date startDate = new java.sql.Date(today.getTime());

        // Get the date a month from now
        java.util.Calendar calendar = java.util.Calendar.getInstance();
        calendar.add(java.util.Calendar.MONTH, 1);
        java.sql.Date endDate = new java.sql.Date(calendar.getTime().getTime());

        // Set the dates in the PreparedStatement
        createRentalStatement.setInt(1, instrument_id);
        createRentalStatement.setDate(2, startDate);
        createRentalStatement.setDate(3, endDate);
        createRentalStatement.setInt(4, student_id);
        // Set the RentalPricingID
        int rentalPricingID = 1; // Replace with the actual RentalPricingID
        createRentalStatement.setInt(5, rentalPricingID);

        int updatedRows = createRentalStatement.executeUpdate();
        if (updatedRows != 1) {
            handleException(failureMsg, null);
        }
    } catch (SQLException sqle) {
        handleException(failureMsg, sqle);
    }

    connection.commit();
}

    /**
     * Terminates renntal with specified ID.
     * @param rentalID The rental to terminate.
     * @throws SoundgoodDBException If unable to terminate the specified rental.
     */
    public void deleteRental(int rentalID) throws SoundgoodDBException, SQLException {
        String failureMsg = "Could not terminate rental: " + rentalID;
        try {
            deleteRentalStatement.setInt(1, rentalID);
            int updatedRows = deleteRentalStatement.executeUpdate();
            if (updatedRows != 1) {
                handleException(failureMsg, null);
            }
        } catch (SQLException sqle) {
            handleException(failureMsg, sqle);
        }

        connection.commit();
    }

    /**
     * Retrieves all available instruments.
     * @return A list with all available instruments. The list is empty if there are no
     *         instruments available.
     * @throws SoundgoodDBException If failed to search for available instruments.
     * @throws SQLException
     */
    public List<Instrument> readInstruments(boolean lockExclusive) throws SoundgoodDBException, SQLException {
        ResultSet result = null;
        PreparedStatement ste;
        try {
            String query = lockExclusive ? listInstrumentsLockForUpdateStatement.toString() : listInstrumentsStatement.toString();
            ste = connection.prepareStatement(query);
            String failureMsg = "Could not list instruments.";
            List<Instrument> instruments = new ArrayList<>();
            try {
                result = ste.executeQuery();
                while (result.next()) {
                    instruments.add(new Instrument( result.getInt(INSTRUMENT_PK_COLUMN_NAME),
                            result.getString(INSTRUMENT_NAME_COLUMN_NAME),
                            result.getString(INSTRUMENT_TYPE_COLUMN_NAME),
                            result.getString(INSTRUMENT_BRAND_COLUMN_NAME),
                            result.getInt(RENTAL_PRICING_PRICE_COLUMN_NAME)));
                }
            } catch (SQLException sqle) {
                handleException(failureMsg, sqle);
            } finally {
                if (ste != null) {
                    ste.close();
                }
            }
            return instruments;
        } catch (SQLException sqle) {
            handleException("Could not list instruments.", sqle);
            return null;
        }
    }

    /**
     * Commits the current transaction.
     * @throws SoundgoodDBException If unable to commit the current transaction.
     */
    public void commit() throws SoundgoodDBException {
        try {
            connection.commit();
        } catch (SQLException e) {
            handleException("Failed to commit", e);
        }
    }

    private void connectToSoundgoodDB() throws ClassNotFoundException, SQLException {
        //Database values here
        connection = DriverManager.getConnection("jdbc:postgresql://localhost:5433/soundgood", "postgres", "1234");
        connection.setAutoCommit(false);
    }

    private void prepareStatements() throws SQLException {
        //Queries needed for all features
        //InstrumentID, RentalStartDate, RentalEndDate, StudentID, RentalPricingID
        createRentalStatement = connection.prepareStatement(
                "INSERT INTO " + RENTAL_TABLE_NAME
                        + " ("
                        + RENTAL_FK_INSTRUMENT_COLUMN_NAME + ", "
                        + RENTAL_TIME_COLUMN_NAME + ", "
                        + RENTAL_TERMINATED_COLUMN_NAME + ", "
                        + RENTAL_FK_STUDENT_COLUMN_NAME + ", "
                        + RENTAL_PRICING_PK_COLUMN_NAME +
                        ") VALUES (?, ?, ?, ?, ?)");

        deleteRentalStatement = connection.prepareStatement(
        "UPDATE " + RENTAL_TABLE_NAME  + " SET " + RENTAL_TERMINATED_COLUMN_NAME + " = CURRENT_DATE WHERE " + RENTAL_PK_COLUMN_NAME +" = ?");

        listInstrumentsStatement = connection.prepareStatement(
                "SELECT * FROM " + INSTRUMENT_TABLE_NAME + " i" +
                        " JOIN " + RENTAL_PRICING_TABLE_NAME + " r ON "
                        + "i."+INSTRUMENT_PK_COLUMN_NAME + " = r."+ INSTRUMENT_PK_COLUMN_NAME +
                        " WHERE i." + INSTRUMENT_PK_COLUMN_NAME + " NOT IN (" +
                        "   SELECT " + RENTAL_FK_INSTRUMENT_COLUMN_NAME +
                        "   FROM " + RENTAL_TABLE_NAME +
                        "   WHERE " + RENTAL_TERMINATED_COLUMN_NAME + " IS NULL OR " +  RENTAL_TERMINATED_COLUMN_NAME + " > CURRENT_DATE );");


        listInstrumentsLockForUpdateStatement = connection.prepareStatement(
                "SELECT * FROM " + INSTRUMENT_TABLE_NAME + " i" +
                        " JOIN " + RENTAL_PRICING_TABLE_NAME + " r ON "
                        + "i."+INSTRUMENT_PK_COLUMN_NAME + " = r."+ INSTRUMENT_PK_COLUMN_NAME +
                        " WHERE i." + INSTRUMENT_PK_COLUMN_NAME + " NOT IN (" +
                        "   SELECT " + RENTAL_FK_INSTRUMENT_COLUMN_NAME +
                        "   FROM " + RENTAL_TABLE_NAME +
                        "   WHERE " + RENTAL_TERMINATED_COLUMN_NAME + " IS NULL OR " +  RENTAL_TERMINATED_COLUMN_NAME + " > CURRENT_DATE ) FOR UPDATE;");
    }
    private void handleException(String failureMsg, Exception cause) throws SoundgoodDBException {
        String completeFailureMsg = failureMsg;
        try {
            connection.rollback();
        } catch (SQLException rollbackExc) {
            completeFailureMsg = completeFailureMsg + ". Failed to rollback transaction:  " + rollbackExc.getMessage();
        }

        if (cause != null) {
            throw new SoundgoodDBException(failureMsg, cause);
        } else {
            throw new SoundgoodDBException(failureMsg);
        }
    }

}
