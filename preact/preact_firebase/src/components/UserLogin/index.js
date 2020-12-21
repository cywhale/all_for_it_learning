import { render } from 'preact';
import { useState, useEffect, useCallback } from 'preact/hooks';
import Cookies from 'universal-cookie';
import { nanoid } from 'nanoid';
import { auth, googleAuthProvider //, database
       } from '../firebase';
import Popup from 'async!../Popup';
import style from './style';
const { odbConfig } = require('./.ssologin.js');

const UserLogin = () => {
  const cookies = new Cookies();
//const history = createBrowserHistory();
  const cookieOpts = {
    path: "/",
    expires: new Date(2020, 11, 3, 15, 20, 0, 30),
    //secure: true
  };
  const ucodelen = 32;
//const [islogin, setIsLogin] = useState(false);
  const [state, setState] = useState({
    ssostate: '',
    redirect: '',
    popup: false
  });
  const [user, setUser] = useState({
    name: '',
    auth: '', //odb, gmail
    photoURL: '',
    //token: '',
  });
  const [ucode, setUcode] = useState({
    str: '',
    //init: false,
    //expired:
  });

  const closePopup = () => {
    //OdbAuth(ucode.str, false); //This works, but try to split OdbAuth only in stateOnChange 
    setState((preState) => ({
      ...preState,
      popup: false
    }));
  }

  const checkUcode = (usercode, codelen=0) => {
    let uc = cookies.get(usercode, { doNotParse: true });
    //console.log('Check ucode availability: ', uc)
    if (uc !== null && uc != undefined) {
      if (uc && uc !== '') {
        if (codelen === 0 || (codelen > 0 && uc.length === codelen)) { return (uc); }
      }
    }
    return('');
  };

  const initUcode = () => {
      let uc = checkUcode('ucode', ucodelen);
      if (uc === '') {
        uc = fetchingUcode(ucodelen);
        cookies.set('ucode', uc, cookieOpts);
      }
      setUcode((preState) => ({
          ...preState,
          str: uc
          //init: true
      }));
      return (uc);
  };

  const OdbAuth = useCallback(async (ucstr, gencode=false) => {
    let ucstrx = ucstr;
    if (gencode && ucstrx === '') ucstrx = initUcode();
    const chkurl =  odbConfig.base + odbConfig.check + "?ucode=" + ucstrx;
    await fetch(chkurl)
       .then(res => res.json())
       .then(sso => {
          if (sso) {
            if (sso.username && sso.username !== "") {
              cookies.set('uauth', 'odb', cookieOpts);
              setState((preState) => ({
                ...preState,
                ssostate: '',
              }));

              return(
                setUser((preState) => ({
                  ...preState,
                  name: sso.username,
                  photoURL: 'https://ecodata.odb.ntu.edu.tw/pub/icon/favicon_tw.png',
                  auth: 'odb'
                }))
              );
            }
          }
          cookies.remove('uauth', { path: '/' });
          setState((preState) => ({
              ...preState,
              ssostate: 'ssofail',
          }));

          return(null
            /*setUser((preState) => ({
              ...preState,
              name: '',
              photoURL: '',
              auth: ''
            }))*/
          );
        });
  }, []);

  const fetchingUcode = (leng=32) => nanoid(leng);

  const renderRedirect = useCallback(() => {
    const rurl = odbConfig.base + odbConfig.login;
    //route(rurl);
    //window.location.href = rurl;
    let location = rurl+"?ucode=" + ucode.str;// + "&nurl="+window.location.href; //no need nurl on iframe
    //history.location; //is an obj with (a.pathname + a.search + a.hash)
    //history.push(rurl+"?ucode=" + ucode.str + "&nurl="+window.location.href);
    setState((preState) => ({
        ...preState,
        redirect: location,
        popup: true
    }));
  }, [ucode.str]);

  const renderFirePopup = useCallback((fireauth, fireprovider) => {
    fireauth.signInWithPopup(fireprovider).then((result) => {
      // This gives you a Google Access Token. You can use it to access the Google API.
      // var token = result.credential.accessToken; //We not use this token currently.
      // The signed-in user info. //var user = result.user;
      setUser((preState) => ({
        ...preState,
        name: result.user.displayName,
        photoURL: result.user.photoURL,
        auth: 'gmail'
      }));
    }).catch((error) => { // Handle Errors here.
      //let errorCode = error.code;
      //let errorMessage = error.message;
      //The email of the user's account used. //let email = error.email;
      //The firebase.auth.AuthCredential type that was used. //let credential = error.credential;
      cookies.remove('uauth', { path: '/' });
      console.log("Gmail login error: ", error.code, "; ", error.message, " with ", error.email, " and ", error.credential);
      alert("Gmail login error: ", error.message);
    })
  }, []);

//auth.signInWithRedirect(googleAuthProvider)}> //https://firebase.google.com/docs/auth/web/google-signin
  const SelSignIn = () => {
    return(
      <div style={style.signIn}>
        <h1>Use ODB SSO or Gmail SignIn</h1>
        <button class={style.button} onClick={() => renderRedirect()}>ODB Sign In</button>
        <button class={style.button}
             onClick={() => renderFirePopup(auth, googleAuthProvider)}>
             Gmail Sign In</button>
      </div>
    );
  };

  const SignOut = () => {
    if (user.auth === 'gmail') { auth.signOut() };
    cookies.remove('ucode', { path: '/' });
    cookies.remove('uauth', { path: '/' });
    setUcode((preState) => ({
      ...preState,
      str: ''
      //init: false,
    }));
    setUser((preState) => ({
      ...preState,
      name: '',
      auth: '',
      photoURL: '',
      //token: ''
    }));
    setState((preState) => ({
      ...preState,
      ssostate: '',
      redirect: '',
      popup: false
    }));
  //setIsLogin(false);
  };

  const CurrUser = () => {
    return (<article class={style.currentUser}>
         <img alt={user.name}
         referrerpolicy="no-referrer"
                     class={style.avatar}
                     src={user.photoURL}
                     width="60" />
            <button class={style.button} onClick={() => SignOut()}>Sign Out</button>
        </article>
    );
  };

  useEffect(() => {
    const waitFireAuth = auth.onAuthStateChanged(
          currUser => {
            if (currUser) {
              cookies.set('uauth', 'gmail', cookieOpts);
              return(
                setUser((preState) => ({
                  ...preState,
                  name: currUser.displayName,
                  photoURL: currUser.photoURL,
                  auth: 'gmail'
                }))
              );
            }
            cookies.remove('uauth', { path: '/' });
            return(null
              /*setUser((preState) => ({
                  ...preState,
                  name: '',
                  photoURL: '',
                  auth: ''
                }))*/
            );
          }
    );

    let uc = ucode.str;
    if (uc === '') {
      uc = initUcode();
    } else {
      const last_auth = checkUcode('uauth', 0);
      if (state.ssostate != 'ssofail' && // first check ODB SSO fail or success
        (last_auth === '' || last_auth === 'odb')) {
        OdbAuth(uc, false);
      } else {
        waitFireAuth();;
      }
    }
  }, [ucode.str, state.ssostate]);

  return (
    <section class={style.flex}>
      { user.name === '' &&
        <div>
        <SelSignIn />
        { state.popup && state.redirect !== '' &&
          <Popup
            srcurl={state.redirect}
            text='Click "Close Button" to hide popup'
            closePopup={ closePopup }
            onChange={ OdbAuth(ucode.str, false) }
          />
        }
        </div>
      }
      { user.name !== '' && <div style="display:flex">
        <CurrUser /></div>
      }
     </section>
  );
};
export default UserLogin;
