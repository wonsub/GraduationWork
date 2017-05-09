using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class kinematic_trigger : MonoBehaviour {


    public GameObject gb;
    Rigidbody[] rbs;
    MeshCollider[] mcs;


   

	void Start()
    {
        rbs = gb.GetComponentsInChildren<Rigidbody>();
        mcs = gb.GetComponentsInChildren<MeshCollider>();

    }
	// Update is called once per frame
	void Update () {
		
	}

   void OnCollisionEnter(Collision col)
    {
        if (col.gameObject.tag != "Floor"){
            StartCoroutine("Split");
        }
    }
    IEnumerator Split()
    {
        foreach (Rigidbody rb in rbs)
        {
            rb.isKinematic = false;
        }
        foreach (MeshCollider mc in mcs)
        {
            mc.enabled = true;
        }
       
        yield return new WaitForSeconds(0.5f);
        gb.GetComponent<Rigidbody>().isKinematic = true;
        yield return new WaitForSeconds(3.0f);
        
        StopCoroutine("Split");
        DestroyObject(gb);
       
    }
}
