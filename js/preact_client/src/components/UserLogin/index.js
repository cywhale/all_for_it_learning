import { render } from 'preact';
import { useState, useEffect, useCallback } from 'preact/hooks';
import Cookies from 'universal-cookie';
import { nanoid } from 'nanoid';
import Redirect from '../Redirect';
const { odbConfig } = require('./.ssologin.js');

const UserLogin = () => {  
  const cookies = new Cookies();
  const cookieOpts = {
    path: "/",
    expires: new Date(2020, 10, 20, 14, 20, 0, 30),
    //secure: true
  };
  const ucodelen = 32;
  const [ucode, setUcode] = useState({
    str: '',
    //expired:
  });
  const [user, setUser] = useState(null);

  const checkUcode = () => {
    let uc = cookies.get('ucode', { doNotParse: true });
    console.log('Check ucode availability: ', uc)
    if (uc !== null && uc != undefined) {
      if (uc && uc !== '' && uc.length === ucodelen) { return (uc); }
    }
    return('');
  };

  const fetchingUcode = (leng=32) => nanoid(leng);

  const renderRedirect = useCallback(() => {
    const rurl = odbConfig.base + odbConfig.login;

    let uc = checkUcode();
    if (uc === '') {
      uc = fetchingUcode(ucodelen);
    }
    cookies.set('ucode', uc, cookieOpts);
    setUcode((preState) => ({
      ...preState,
      str: uc
    }));
    console.log(ucode.str);

    return (
      <Redirect path="/login" to={rurl} />
    );
  }, [ucode]);


  const OdbSignIn = () => {
    return(
      <div style='align-items:center;display:flex;flex-direction:column;flex-grow:1;justify-content:center;'>
        <h1>ODB SSO SignIn</h1>
        <button onClick={() => renderRedirect()}>Sign In</button>
      </div>
    );
  };

  const OdbSignOut = () => {
    setUser(null);
    return (
      <Redirect path="/" to="/" />
    );
  };

  const OdbUser = () => {
//    const { user } = props;
/*
         <img alt={user.displayName} 
         referrerpolicy="no-referrer" 
                     class={style.avatar} 
                     src={user.photoURL} 
                     width="60" /> */
    return (
      <div style='align-items:center;align-self:stretch;display:flex;justify-content:center;padding-top:16px;'>
            <h1>Welcome! {user}</h1>
            <button onClick={() => OdbSignOut()}>Sign Out</button>
      </div>
    );
  };

  const OdbAuth = async () => {
    const chkurl =  odbConfig.base + odbConfig.check + "?ucode=" + ucode;
    await fetch(chkurl)
      .then(res => res.json())
      .then(sso => {
        if (sso) {
          if (sso.username && sso.username !== "") {
            return(setUser(sso.username));
          }
        }
        return(setUser(null));
      });
  };

  useEffect(() => {
    if (checkUcode() !== '') {
      OdbAuth();
    }
  }, [ucode]);

//export default class UserHandler extends Component {
  //render() {
  return (
    <section style="display:flex;">
      {!user && <OdbSignIn />}
      { user && <div style="display:flex">
        <OdbUser /></div> }
   </section>
  );
  //}
};
export default UserLogin;
