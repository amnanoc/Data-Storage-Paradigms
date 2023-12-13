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

 package model;

 /**
  * An instrument in the school.
  */
 public class Instrument implements InstrumentDTO {
     private int price;
     private int instrument_id;
     private String brand;

     private String name;
     private String instrument_type;
 
     /**
      * Creates an instrument of specified type, brand and price, having provided ID.
      *
      * @param instrument_id     The instrument ID.
      * @param name     The instrument name.
      * @param instrument_type The instrument type.
      * @param brand    The instrument brand.
      * @param price    The rental fee.
      */
     public Instrument(int instrument_id, String name, String instrument_type, String brand, int price) {
         this.instrument_id = instrument_id;
         this.name = name;
         this.instrument_type = instrument_type;
         this.brand = brand;
         this.price = price;
     }
 
     /**
      * @return The ID.
      */
     public Integer getInstrumentID() {
         return instrument_id;
     }
 
     /**
      * @return The type.
      */
     public String getInstrumentType() {
         return instrument_type;
     }
 
     /**
      * @return The brand.
      */
     public String getInstrumentBrand() {
         return brand;
     }

     /**
      * @return The price.
      */
      public Integer getInstrumentPrice() {
        return price;
    }
 
     /**
      * @return A string representation of all fields in this object.
      */
     @Override
     public String toString() {
         return "Instrument: [" +
                 "ID: " +
                 instrument_id +
                 " Name: " +
                 name +
                 ", type: " +
                 instrument_type +
                 ", brand: " +
                 brand +
                 ", price: " +
                 price +
                 "]";
     }
 }
 