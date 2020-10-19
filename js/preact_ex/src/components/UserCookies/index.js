//use hooks for https://jsfiddle.net/vittore/nyrmcmcy/2/
/** @jsx h */
import { render } from 'preact';
import { useState, useEffect, useRef } from 'preact/hooks';
import "../../style/style_usercookies.scss";
import style from "./style";

const UserCookies = () => {

  const Nothing = () => null;
  const [root, setRoot] = useState(null);
  const [shown, setShown] = useState(false);
  const cookieRef = useRef(null);

  const getCookie = () => {
    console.log('getcookies:', document.cookie)
    return (document.cookie || '').split(';')
  };

  const setCookie = (c) => {
    console.log('setcookies before:',document.cookie);
    let cookies = document.cookie;
    document.cookie = cookies + ';' + c;
    console.log('setcookies after:', document.cookie);
  };

  const CookiePopup = () => {
//class CookiePopup extends Component {
//  constructor() {
//      super();
        // set initial time:
    const [popup, setPopup] = useState({
        //this.state.closed = false;
        details: false //this.state.details = false;
    });
//  componentDidMount() {// update time every second }
//  componentWillUnmount() {// stop when not renderable }

    const clickClose = () => {
      //console.log('click close');
      const d = document.getElementById('useCookies');
      //if (!state.close) {
      setCookie('sylogentpolicyseen=true');
      render(<Nothing />, d, root);
      /* setPopup((preState) => ({
          ...preState,
          shown: true
      })); */
    };

    const clickDetails = () => {
      //console.log('click details');
      setPopup( { details: true }) //this.
      /* setPopup((preState) => ({
          ...preState,
          details: true
      })); */
    };

    //render(props, state) {
    const details = popup.details;
    return(
        <div class={details? 'details':''}><p>
          <a class='close' onClick={clickClose}>×</a>
          This site uses cookies. By continuing to use this site, you are agreeing to our use of cookies. 
          {!details? <a onClick={clickDetails}>» Find out more</a> : ''}
          {details && <p>
            We may collect and process non-personal information about your visit to this website, such as noting some of the pages you visit and some of the searches you perform. Such anonymous information is used by us to help improve the contents of the site and to compile aggregate statistics about individuals using our site for internal research purposes only. In doing this, we may install cookies.
          </p>}</p>
        </div>
    );
  };

  const checkCookies = () => {
    let c = getCookie();
    console.log(c)
    return (c.indexOf('sylogentpolicyseen=true') > -1);
  }

  const initCookies = ()  => {
    if (!checkCookies()) {
      //let d = document.createElement('div')
      //d.id = 'useCookies';
      //document.body.appendChild(d);
      setRoot(render(<CookiePopup />, cookieRef.current)); //document.getElementById('useCookies')));
      //setCookie('sylogentpolicyseen=true');
    }
  };

  useEffect(() => {
     initCookies();
  }, []);

  let showClass;
  if (shown) {
    showClass=`${style.cookiediv} ${style.shown}`;
  } else {
    showClass=`${style.cookiediv}`
  }
  console.log("showClass: " + showClass + " when isShown is: " + shown);

  return(
    <div id='useCookies' class={showClass} isShown={shown} ref={cookieRef} />
  );
};
export default UserCookies;
