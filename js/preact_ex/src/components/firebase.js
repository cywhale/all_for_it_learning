import firebase from "firebase/app";
import 'firebase/database';
import 'firebase/auth';

const credentials  = import("../../.credentials.development.js");

firebase.initializeApp(credentials.firebase);

export default firebase;

export const database = firebase.database();
export const auth = firebase.auth();
export const googleAuthProvider = new firebase.auth.GoogleAuthProvider();
