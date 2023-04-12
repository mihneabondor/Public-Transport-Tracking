//
//  Constants.swift
//  Public Transport Tracking
//
//  Created by Mihnea on 4/3/23.
//

import Foundation

class Constants {
    public static let USER_DEFAULTS_FAVORITES = "com.ptt.favorite"
    public static let USER_DEFAULTS_SPLASHSCREEN = "com.ptt.splashscreen"
    public static let USER_DEFAULTS_NEWS_LAST_DATE = "com.ptt.newsLastDate"
    public static let routes : [Route] = [Route(routeId: 1, agencyId: 2, routeShortName: "1", routeLongName: "Str. Bucium - P-ta 1 Mai", routeColor: "#f3513c", routeType: 11), Route(routeId: 2, agencyId: 2, routeShortName: "100", routeLongName: "P-ta Garii - B-dul Muncii", routeColor: "#f3513c", routeType: 0), Route(routeId: 3, agencyId: 2, routeShortName: "101", routeLongName: "Str. Bucium - P-ta Garii", routeColor: "#f3513c", routeType: 0), Route(routeId: 4, agencyId: 2, routeShortName: "102", routeLongName: "Str. Bucium - B-dul Muncii", routeColor: "#f3513c", routeType: 0), Route(routeId: 5, agencyId: 2, routeShortName: "102L", routeLongName: "Str. Bucium - DEPOU", routeColor: "#f3513c", routeType: 0), Route(routeId: 6, agencyId: 2, routeShortName: "19", routeLongName: "P-ta M. Viteazul - Str. E. Quinet", routeColor: "#f3513c", routeType: 3), Route(routeId: 7, agencyId: 2, routeShortName: "20", routeLongName: "Col. Borhanci - P-ta Stefan cel Mare", routeColor: "#f3513c", routeType: 3), Route(routeId: 8, agencyId: 2, routeShortName: "21", routeLongName: "P-ta M. Viteazul - Cart. Buna Ziua", routeColor: "#f3513c", routeType: 3), Route(routeId: 9, agencyId: 2, routeShortName: "22", routeLongName: "P-ta Garii - Str. I. Moldovan", routeColor: "#f3513c", routeType: 3), Route(routeId: 10, agencyId: 2, routeShortName: "23", routeLongName: "P-ta M. Viteazul - C.U.G", routeColor: "#f3513c", routeType: 11), Route(routeId: 12, agencyId: 2, routeShortName: "24", routeLongName: "Str. Unirii - Str. Bucium", routeColor: "#f3513c", routeType: 3), Route(routeId: 13, agencyId: 2, routeShortName: "24B", routeLongName: "Str. Unirii - Polus Center", routeColor: "#f3513c", routeType: 3), Route(routeId: 14, agencyId: 2, routeShortName: "25", routeLongName: "Str. Bucium - Str. Unirii", routeColor: "#f3513c", routeType: 11), Route(routeId: 15, agencyId: 2, routeShortName: "25N", routeLongName: "Str. Bucium - Str. Unirii", routeColor: "#f3513c", routeType: 3), Route(routeId: 16, agencyId: 2, routeShortName: "26", routeLongName: "Cart. Grigorescu - B-dul Muncii", routeColor: "#f3513c", routeType: 3), Route(routeId: 17, agencyId: 2, routeShortName: "26L", routeLongName: "Cart. Grigorescu - Str. Emerson", routeColor: "#f3513c", routeType: 3), Route(routeId: 18, agencyId: 2, routeShortName: "27", routeLongName: "Cart. Grigorescu - P-ta Garii", routeColor: "#f3513c", routeType: 3), Route(routeId: 19, agencyId: 2, routeShortName: "28", routeLongName: "Cart. Grigorescu - P-ta M. Viteazul", routeColor: "#f3513c", routeType: 3), Route(routeId: 20, agencyId: 2, routeShortName: "28B", routeLongName: "Polus Center - P-ta M. Viteazul", routeColor: "#f3513c", routeType: 3), Route(routeId: 21, agencyId: 2, routeShortName: "29", routeLongName: "Roata Faget - Str. Henri Barbusse", routeColor: "#693cf3", routeType: 3), Route(routeId: 22, agencyId: 2, routeShortName: "3", routeLongName: "Str. Unirii - P-ta Garii", routeColor: "#f3513c", routeType: 11), Route(routeId: 23, agencyId: 2, routeShortName: "30", routeLongName: "Cart. Grigorescu - Str. Aurel Vlaicu", routeColor: "#f3513c", routeType: 3), Route(routeId: 24, agencyId: 2, routeShortName: "31", routeLongName: "P-ta M. Viteazul - Calea Baciului", routeColor: "#f3513c", routeType: 3), Route(routeId: 25, agencyId: 2, routeShortName: "32", routeLongName: "Str. C. Brancusi - P-ta M. Viteazul", routeColor: "#f3513c", routeType: 3), Route(routeId: 26, agencyId: 2, routeShortName: "32B", routeLongName: "Str. C. Brancusi - P-ta Garii", routeColor: "#f3513c", routeType: 3), Route(routeId: 27, agencyId: 2, routeShortName: "33", routeLongName: "Aleea Baisoara - P-ta M. Viteazul", routeColor: "#f3513c", routeType: 3), Route(routeId: 28, agencyId: 2, routeShortName: "34", routeLongName: "Aleea Baisoara - P-ta 1 Mai", routeColor: "#f3513c", routeType: 3), Route(routeId: 29, agencyId: 2, routeShortName: "35", routeLongName: "Cart. Zorilor - P-ta Garii", routeColor: "#f3513c", routeType: 3), Route(routeId: 30, agencyId: 2, routeShortName: "36B", routeLongName: "P-ta M. Viteazul - Str. Ion Ionescu de la Brad", routeColor: "#f3513c", routeType: 3), Route(routeId: 31, agencyId: 2, routeShortName: "36L", routeLongName: "P-ta M. Viteazul - Str. Emerson", routeColor: "#f3513c", routeType: 3), Route(routeId: 32, agencyId: 2, routeShortName: "37", routeLongName: "P-ta M. Viteazul - Str. Romulus Vuia", routeColor: "#f3513c", routeType: 3), Route(routeId: 33, agencyId: 2, routeShortName: "38", routeLongName: "P-ta M. Viteazul - Str. Vanatorului", routeColor: "#f3513c", routeType: 3), Route(routeId: 34, agencyId: 2, routeShortName: "39", routeLongName: "P-ta M. Viteazul - Valea Chintaului", routeColor: "#f3513c", routeType: 3), Route(routeId: 35, agencyId: 2, routeShortName: "39L", routeLongName: "P-ta M. Viteazul - Catun", routeColor: "#f3513c", routeType: 3), Route(routeId: 36, agencyId: 2, routeShortName: "4", routeLongName: "Str. Aurel Vlaicu - P-ta Garii", routeColor: "#f3513c", routeType: 11), Route(routeId: 37, agencyId: 2, routeShortName: "40", routeLongName: "P-ta Stefan cel Mare - Colonia Faget", routeColor: "#f3513c", routeType: 3), Route(routeId: 38, agencyId: 2, routeShortName: "40S", routeLongName: "P-ta Stefan cel Mare - Calea Turzii", routeColor: "#f3513c", routeType: 3), Route(routeId: 39, agencyId: 2, routeShortName: "41", routeLongName: "Cart. Grigorescu - P-ta 1 Mai", routeColor: "#f3513c", routeType: 3), Route(routeId: 40, agencyId: 2, routeShortName: "42", routeLongName: "P-ta M. Viteazul - Str. Campului", routeColor: "#f3513c", routeType: 3), Route(routeId: 41, agencyId: 2, routeShortName: "43", routeLongName: "Cart. Grigorescu - Cart. Zorilor", routeColor: "#f3513c", routeType: 3), Route(routeId: 42, agencyId: 2, routeShortName: "43B", routeLongName: "Cart. Grigorescu - Calea Turzii", routeColor: "#f3513c", routeType: 3), Route(routeId: 43, agencyId: 2, routeShortName: "43P", routeLongName: "Polus Center - Cart. Zorilor", routeColor: "#f3513c", routeType: 3), Route(routeId: 44, agencyId: 2, routeShortName: "46", routeLongName: "Str. Eugen Ionesco - P-ta Stefan cel Mare", routeColor: "#f3513c", routeType: 3), Route(routeId: 45, agencyId: 2, routeShortName: "46B", routeLongName: "Cart. Zorilor - Str. Aurel Vlaicu", routeColor: "#f3513c", routeType: 3), Route(routeId: 46, agencyId: 2, routeShortName: "47", routeLongName: "P-ta M. Viteazul - Str. Harghitei", routeColor: "#f3513c", routeType: 3), Route(routeId: 47, agencyId: 2, routeShortName: "48", routeLongName: "Aleea Baisoara - B-dul Muncii", routeColor: "#f3513c", routeType: 3), Route(routeId: 48, agencyId: 2, routeShortName: "48L", routeLongName: "Aleea Baisoara - Str. Emerson", routeColor: "#f3513c", routeType: 3), Route(routeId: 49, agencyId: 2, routeShortName: "5", routeLongName: "P-ta Garii - Aeroport", routeColor: "#f3513c", routeType: 11), Route(routeId: 50, agencyId: 2, routeShortName: "50", routeLongName: "Cart. Zorilor - B-dul Muncii", routeColor: "#f3513c", routeType: 3), Route(routeId: 51, agencyId: 2, routeShortName: "50L", routeLongName: "Cart. Zorilor - Str. Emerson", routeColor: "#f3513c", routeType: 3), Route(routeId: 52, agencyId: 2, routeShortName: "52", routeLongName: "Str. Bucium - Str. Plevnei", routeColor: "#f3513c", routeType: 3), Route(routeId: 53, agencyId: 2, routeShortName: "6", routeLongName: "Str. Bucium - Str. Aurel Vlaicu", routeColor: "#f3513c", routeType: 11), Route(routeId: 54, agencyId: 2, routeShortName: "7", routeLongName: "Str. Aurel Vlaicu - Str. Izlazului", routeColor: "#f3513c", routeType: 11), Route(routeId: 55, agencyId: 2, routeShortName: "8", routeLongName: "P-ta M. Viteazul - Str. Traian Vuia", routeColor: "#f3513c", routeType: 3), Route(routeId: 56, agencyId: 2, routeShortName: "8L", routeLongName: "Maresal C-tin Prezan - AGRO TRANSILVANIA", routeColor: "#f3513c", routeType: 3), Route(routeId: 57, agencyId: 2, routeShortName: "87B", routeLongName: "Str. Bucium - Polus Center", routeColor: "#f3513c", routeType: 3), Route(routeId: 58, agencyId: 2, routeShortName: "9", routeLongName: "Str. Bucium - P-ta Garii", routeColor: "#f3513c", routeType: 3), Route(routeId: 59, agencyId: 2, routeShortName: "M11", routeLongName: "P-ta Cipariu - Feleacu", routeColor: "#f3513c", routeType: 3), Route(routeId: 60, agencyId: 2, routeShortName: "M12", routeLongName: "P-ta Cipariu - Valcele", routeColor: "#f3513c", routeType: 3), Route(routeId: 61, agencyId: 2, routeShortName: "M13", routeLongName: "P-ta Stefan cel Mare - Gheorgheni", routeColor: "#f3513c", routeType: 3), Route(routeId: 62, agencyId: 2, routeShortName: "M16", routeLongName: "P-ta Stefan cel Mare - Pasaj Ciurila", routeColor: "#f3513c", routeType: 3), Route(routeId: 63, agencyId: 2, routeShortName: "M21", routeLongName: "Bucium - Floresti Cetate", routeColor: "#f3513c", routeType: 3), Route(routeId: 64, agencyId: 2, routeShortName: "M22", routeLongName: "Bucium - Floresti Sesul de Sus", routeColor: "#f3513c", routeType: 3), Route(routeId: 65, agencyId: 2, routeShortName: "M23", routeLongName: "Calea Floresti - Luna de Sus", routeColor: "#f3513c", routeType: 3), Route(routeId: 66, agencyId: 2, routeShortName: "M24", routeLongName: "Str. Bucium - Floresti / Ferma", routeColor: "#f3513c", routeType: 3), Route(routeId: 67, agencyId: 2, routeShortName: "M25", routeLongName: "Str. Bucium - Tauti", routeColor: "#f3513c", routeType: 3), Route(routeId: 68, agencyId: 2, routeShortName: "M26", routeLongName: "P-ta MIhai Viteazul - Floresti / Cetate", routeColor: "#f3513c", routeType: 3), Route(routeId: 69, agencyId: 2, routeShortName: "M31", routeLongName: "P-ta M.Viteazul - Comuna Baciu", routeColor: "#f3513c", routeType: 3), Route(routeId: 70, agencyId: 2, routeShortName: "M32", routeLongName: "P-ta Garii - Baciu / Suceagu", routeColor: "#f3513c", routeType: 3), Route(routeId: 71, agencyId: 2, routeShortName: "M33", routeLongName: "P-ta Garii - Corusu / Salistea Noua", routeColor: "#f3513c", routeType: 3), Route(routeId: 72, agencyId: 2, routeShortName: "M34", routeLongName: "P-ta Garii - Baciu / Mera", routeColor: "#f3513c", routeType: 3), Route(routeId: 73, agencyId: 2, routeShortName: "M35", routeLongName: "P-ta Garii - Popesti Deal", routeColor: "#f3513c", routeType: 3), Route(routeId: 74, agencyId: 2, routeShortName: "M37", routeLongName: "Cluj-Napoca - Feiurdeni / Satu Lung", routeColor: "#f3513c", routeType: 3), Route(routeId: 75, agencyId: 2, routeShortName: "M38", routeLongName: "Cluj-Napoca - Sanmartin", routeColor: "#f3513c", routeType: 3), Route(routeId: 76, agencyId: 2, routeShortName: "M39", routeLongName: "Cluj-Napoca - Chinteni Lac", routeColor: "#f3513c", routeType: 3), Route(routeId: 77, agencyId: 2, routeShortName: "M39L", routeLongName: "Cluj-Napoca - Deus", routeColor: "#f3513c", routeType: 3), Route(routeId: 78, agencyId: 2, routeShortName: "M41", routeLongName: "Str. Aurel Vlaicu - Apahida", routeColor: "#f3513c", routeType: 3), Route(routeId: 79, agencyId: 2, routeShortName: "M41L", routeLongName: "Str. Aurel Vlaicu - Campenesti", routeColor: "#f3513c", routeType: 3), Route(routeId: 80, agencyId: 2, routeShortName: "M42", routeLongName: "Str. Aurel Vlaicu - Sannicoara", routeColor: "#f3513c", routeType: 3), Route(routeId: 81, agencyId: 2, routeShortName: "M42L", routeLongName: "Str. Aurel Vlaicu -  Parcul Industrial Nervia", routeColor: "#f3513c", routeType: 3), Route(routeId: 82, agencyId: 2, routeShortName: "M43", routeLongName: "Str. Aurel Vlaicu - Dezmir", routeColor: "#f3513c", routeType: 3), Route(routeId: 83, agencyId: 2, routeShortName: "M44", routeLongName: "Str. A. Vlaicu - Corpadea", routeColor: "#f3513c", routeType: 3), Route(routeId: 84, agencyId: 2, routeShortName: "M45", routeLongName: "Str. A. Vlaicu - Pata", routeColor: "#f3513c", routeType: 3), Route(routeId: 87, agencyId: 2, routeShortName: "cora2", routeLongName: "cora2", routeColor: "#000", routeType: 3), Route(routeId: 88, agencyId: 2, routeShortName: "18", routeLongName: "Str. Posada - Str. Voievod Gelu", routeColor: "#000", routeType: 3), Route(routeId: 89, agencyId: 2, routeShortName: "88S", routeLongName: "88S", routeColor: "#000", routeType: 3), Route(routeId: 93, agencyId: 2, routeShortName: "TE1", routeLongName: "Transport Elevi Manastur", routeColor: "#000", routeType: 3), Route(routeId: 94, agencyId: 2, routeShortName: "TE2", routeLongName: "Transport Elevi Bucium", routeColor: "#000", routeType: 3), Route(routeId: 95, agencyId: 2, routeShortName: "TE3", routeLongName: "Transport Elevi Zorilor", routeColor: "#000", routeType: 3), Route(routeId: 96, agencyId: 2, routeShortName: "TE4", routeLongName: "Transport Elevi Unirii", routeColor: "#000", routeType: 3), Route(routeId: 97, agencyId: 2, routeShortName: "TE5", routeLongName: "Transport Elevi IRA", routeColor: "#000", routeType: 3), Route(routeId: 105, agencyId: 2, routeShortName: "52L", routeLongName: "52L Bucium - EMERSON", routeColor: "#000", routeType: 3), Route(routeId: 106, agencyId: 2, routeShortName: "TE6", routeLongName: "Transport Elevi ", routeColor: "#000", routeType: 3), Route(routeId: 107, agencyId: 2, routeShortName: "TE7", routeLongName: "Transport Elevi", routeColor: "#000", routeType: 3), Route(routeId: 108, agencyId: 2, routeShortName: "TE8", routeLongName: "Transport Elevi ", routeColor: "#000", routeType: 3), Route(routeId: 109, agencyId: 2, routeShortName: "TE9", routeLongName: "Transport Elevi", routeColor: "#000", routeType: 3), Route(routeId: 110, agencyId: 2, routeShortName: "TE10", routeLongName: "Transport Elevi", routeColor: "#000", routeType: 3), Route(routeId: 111, agencyId: 2, routeShortName: "TE11", routeLongName: "Transport Elevi", routeColor: "#000", routeType: 3), Route(routeId: 112, agencyId: 2, routeShortName: "TE12", routeLongName: "Transport Elevi", routeColor: "#000", routeType: 3), Route(routeId: 113, agencyId: 2, routeShortName: "45", routeLongName: "45 Zorilor - Unirii", routeColor: "#000", routeType: 3), Route(routeId: 114, agencyId: 2, routeShortName: "44", routeLongName: "44 Grigorescu - Unirii", routeColor: "#000", routeType: 3), Route(routeId: 115, agencyId: 2, routeShortName: "53", routeLongName: "53 P-ta Agroalimentara IRA - P-ta Mihai Viteazul", routeColor: "#000", routeType: 3), Route(routeId: 116, agencyId: 2, routeShortName: "29S", routeLongName: "29S", routeColor: "#000", routeType: 3), Route(routeId: 117, agencyId: 2, routeShortName: "2", routeLongName: "Ion Mester - P-ta Garii", routeColor: "#000", routeType: 11), Route(routeId: 119, agencyId: 2, routeShortName: "10", routeLongName: "Gheorgheni - CUG", routeColor: "#000", routeType: 11), Route(routeId: 120, agencyId: 2, routeShortName: "14", routeLongName: "Ion Mester - CUG", routeColor: "#000", routeType: 11), Route(routeId: 121, agencyId: 2, routeShortName: "M51", routeLongName: "Bucium - Peco Gilau", routeColor: "#000", routeType: 3), Route(routeId: 122, agencyId: 2, routeShortName: "M52", routeLongName: "Bucium - Somesul Rece", routeColor: "#000", routeType: 3), Route(routeId: 124, agencyId: 2, routeShortName: "cora1", routeLongName: "cora1", routeColor: "#000", routeType: 3), Route(routeId: 129, agencyId: 2, routeShortName: "8D", routeLongName: "P-ta Marasti - AGRO TRANSILVANIA", routeColor: "#000", routeType: 3), Route(routeId: 131, agencyId: 2, routeShortName: "46L", routeLongName: "P-ţa Ştefan cel Mare  -  Colonia Faget", routeColor: "#000", routeType: 3), Route(routeId: 132, agencyId: 2, routeShortName: "TE13", routeLongName: "Transport Elevi", routeColor: "#000", routeType: 3), Route(routeId: 133, agencyId: 2, routeShortName: "TE14", routeLongName: "Transport Elevi", routeColor: "#000", routeType: 3), Route(routeId: 134, agencyId: 2, routeShortName: "52B", routeLongName: "Str. Bucium - Str. I. Ionescu de la Brad", routeColor: "#000", routeType: 3), Route(routeId: 135, agencyId: 2, routeShortName: "123", routeLongName: "test", routeColor: "#000", routeType: 0)]
    public static let linii = ["102L", "102", "101", "100L", "100", "53", "52L", "52", "50L", "50D", "50", "48L", "48", "47", "46L", "46B", "46", "45", "44", "43P", "43B", "43", "42", "41", "40S", "40", "39L", "39", "38", "37", "36L", "36B", "35", "34", "33", "32B", "32", "31", "30", "29S", "29", "28B", "28", "27", "26L", "26", "25N", "25", "24B", "24", "23", "22", "21", "20", "19", "18", "14", "10", "9", "8L", "8", "7", "6", "5", "4", "3", "2", "1"]
}
