using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using ÇalışLanAMK.Models;

namespace ÇalışLanAMK.Controllers
{
    public class HomeController : Controller
    {
        ArmaganYuzukEntities arm = new ArmaganYuzukEntities();
        
        public ActionResult Index()
        {
            
            
            return View(arm);
        }

        public ActionResult About()
        {
            ViewBag.Message = "Your application description page.";

            return View();
        }

        public ActionResult Contact()
        {
            ViewBag.Message = "Your contact page.";

            return View();
        }

        public ActionResult SatinAlim(string Ad, string Sifre)
        {


            return Redirect("Index");
        }

        public ActionResult HesapEkle(string Eposta, string Ad, string Soyad, string Nick, string Sifre)
        {
            foreach (var i in arm.Kullanici.ToList())
            {
                if (i.kullanici_ad == Nick || i.eposta == Eposta)
                {
                    return Redirect("Index");
                }
            }

            Kullanici kul = new Kullanici { eposta = Eposta, ad = Ad, soyad = Soyad, kullanici_ad = Nick, kullanici_sifre = Sifre };
            
            return Redirect("Index");
        }
    }
}