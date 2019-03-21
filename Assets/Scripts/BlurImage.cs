using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BlurImage : MonoBehaviour {

    [SerializeField]
    private UnityEngine.UI.Image image;

    [SerializeField]
    private int step = 1;

	// Use this for initialization
	void Start () {
		
	}
	
	// Update is called once per frame
	void Update () {
        SetMaterialParams();
    }

    private void SetMaterialParams()
    {

    }
}
