#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
Automated Immune Cell Type Annotation using CellTypist

This script annotates scRNA-seq data with immune cell types using pre-trained CellTypist models.
Input must be log1p normalized to 10,000 counts per cell.

Usage:
    python annotate_immune_cells.py input.h5ad --output annotated.h5ad
    python annotate_immune_cells.py input.h5ad --model Immune_All_High.pkl --no-majority-voting
"""

import argparse
import sys
from pathlib import Path
import warnings

# Suppress warnings
warnings.filterwarnings('ignore')

import scanpy as sc
import celltypist
from celltypist import models
import numpy as np
from scipy import sparse


def check_normalization(adata):
    """Verify and fix normalization."""
    # Check for raw counts
    if sparse.issparse(adata.X):
        max_val = adata.X.data.max() if len(adata.X.data) > 0 else 0
    else:
        max_val = adata.X.max()

    print(f"[INFO] Data max value: {max_val:.2f}")
    
    # Heuristic: Raw counts usually have max > 50
    is_raw = max_val > 50
    if is_raw:
        print("[WARN] Detected raw counts (max > 50). Normalizing...")
        sc.pp.normalize_total(adata, target_sum=1e4)
        sc.pp.log1p(adata)
        return True

    # Check totals
    try:
        if sparse.issparse(adata.X):
            totals = np.array(adata.X.expm1().sum(axis=1)).flatten()
        else:
            totals = np.array(np.expm1(adata.X).sum(axis=1)).flatten()
    except Exception as e:
        print(f"[WARN] Error calculating totals: {e}")
        return False
        
    mean_total = totals.mean()
    print(f"[INFO] Mean total counts (expm1): {mean_total:.0f}")
    
    if abs(mean_total - 10000) > 1000:
        print(f"[WARN] Data invalid (mean={mean_total:.0f}). Re-normalizing...")
        
        # Un-log
        print("   Step 1: Un-logging (expm1)...")
        if sparse.issparse(adata.X):
            adata.X = adata.X.expm1()
        else:
            adata.X = np.expm1(adata.X)
            
        # Check intermediate
        if sparse.issparse(adata.X):
            max_inter = adata.X.data.max() if len(adata.X.data) > 0 else 0
        else:
            max_inter = adata.X.max()
        print(f"   Max after unlog: {max_inter:.2f}")

        print("   Step 2: Normalizing to 10k...")
        sc.pp.normalize_total(adata, target_sum=1e4)
        
        # Check intermediate
        if sparse.issparse(adata.X):
             # Just checking mean sum
            sum_inter = np.array(adata.X.sum(axis=1)).flatten().mean()
        else:
            sum_inter = np.array(adata.X.sum(axis=1)).flatten().mean()
        print(f"   Mean sum after normalize: {sum_inter:.2f}")

        print("   Step 3: Log1p...")
        sc.pp.log1p(adata)
        
        # Check range
        if sparse.issparse(adata.X):
            min_val = adata.X.data.min() if len(adata.X.data) > 0 else 0
            max_val = adata.X.data.max() if len(adata.X.data) > 0 else 0
        else:
            min_val = adata.X.min()
            max_val = adata.X.max()
            
        print(f"[INFO] Post-norm range: [{min_val:.4f}, {max_val:.4f}]")
        
        if min_val < 0:
            print("   Clipping negatives to 0...")
            if sparse.issparse(adata.X):
                adata.X.data[adata.X.data < 0] = 0
            else:
                adata.X[adata.X < 0] = 0

        if max_val > 9.22:
            print(f"   Clipping values > 9.22...")
            if sparse.issparse(adata.X):
                adata.X.data[adata.X.data > 9.22] = 9.22
            else:
                adata.X[adata.X > 9.22] = 9.22
        
        # Verify final
        if sparse.issparse(adata.X):
            final_total = np.array(adata.X.expm1().sum(axis=1)).flatten().mean()
        else:
            final_total = np.array(np.expm1(adata.X).sum(axis=1)).flatten().mean()
        print(f"[INFO] Final verified mean total: {final_total:.0f}")
        sys.stdout.flush()
        
    return True


def annotate_cells(
    input_path: str,
    output_path: str,
    model_name: str = 'Immune_All_Low.pkl',
    majority_voting: bool = True,
    plot_results: bool = False,
    plot_dir: str = None
):
    """Annotate cells using CellTypist."""
    print(f"[LOAD] Loading data from: {input_path}")
    adata = sc.read_h5ad(input_path)
    print(f"   Shape: {adata.shape[0]} cells x {adata.shape[1]} genes")
    
    # Check for NaNs and fix them immediately
    has_nans = False
    if sparse.issparse(adata.X):
        if np.isnan(adata.X.data).any():
            has_nans = True
            print("[WARN] Warning: Input data contains NaNs. Replacing with 0.")
            adata.X.data = np.nan_to_num(adata.X.data)
    else:
        if np.isnan(adata.X).any():
            has_nans = True
            print("[WARN] Warning: Input data contains NaNs. Replacing with 0.")
            adata.X = np.nan_to_num(adata.X)
    
    # Check normalization
    check_normalization(adata)
    
    # Ensure model is available
    print(f"\n[MODEL] Loading model: {model_name}")
    try:
        model = models.Model.load(model_name)
    except Exception as e:
        print(f"   Model not found or error loading locally ({e}). Downloading...")
        models.download_models(model=model_name)
        model = models.Model.load(model_name)
    
    print(f"   Cell types in model: {len(model.cell_types)}")
    
    # Run annotation
    print(f"\n[ANNOT] Annotating cells (majority_voting={majority_voting})...")
    # Note: celltypist.annotate does internal check_expression. 
    # Since we fixed normalization, it should pass.
    predictions = celltypist.annotate(
        adata,
        model=model_name,
        majority_voting=majority_voting
    )
    
    # Convert to AnnData with predictions
    adata = predictions.to_adata(insert_labels=True, insert_conf=True)
    
    # Print summary
    print("\n[STATS] Annotation Summary:")
    if majority_voting and 'majority_voting' in adata.obs:
        label_col = 'majority_voting'
    else:
        if majority_voting:
             print("[WARN] 'majority_voting' requested but not found in results (dataset too small?). Using raw predictions.")
        label_col = 'predicted_labels'
    
    print(f"   Using column: {label_col}")
    value_counts = adata.obs[label_col].value_counts()
    print(f"   Unique cell types: {len(value_counts)}")
    print("\n   Top 10 cell types:")
    for ct, count in value_counts.head(10).items():
        pct = 100 * count / adata.n_obs
        print(f"      {ct}: {count} ({pct:.1f}%)")
    
    # Generate plots if requested
    if plot_results:
        print("\n[PLOT] Generating plots...")
        if plot_dir:
            if not Path(plot_dir).exists():
                Path(plot_dir).mkdir(parents=True)
            sc.settings.figdir = plot_dir
        
        # Compute UMAP if not present
        if 'X_umap' not in adata.obsm:
            print("   Computing UMAP...")
            if 'X_pca' not in adata.obsm:
                sc.pp.pca(adata)
            sc.pp.neighbors(adata)
            sc.tl.umap(adata)
        
        # Plot predictions
        save_name = f'_celltypist_{model_name.replace(".pkl", "")}.png'
        sc.pl.umap(adata, color=[label_col, 'conf_score'], 
                   save=save_name, show=False)
        print(f"   Saved UMAP plot to {plot_dir if plot_dir else 'current dir'}/{save_name}")
    
    # Save results
    print(f"\n[SAVE] Saving annotated data to: {output_path}")
    adata.write(output_path)
    
    print("\n[DONE] Annotation complete!")
    return adata


def main():
    parser = argparse.ArgumentParser(
        description='Annotate scRNA-seq data with CellTypist immune cell models',
        formatter_class=argparse.RawDescriptionHelpFormatter
    )
    
    parser.add_argument('input', help='Input h5ad file')
    parser.add_argument('--output', '-o', required=True, help='Output h5ad file path')
    parser.add_argument('--model', '-m', default='Immune_All_Low.pkl',
                        help='CellTypist model name')
    parser.add_argument('--no-majority-voting', action='store_true',
                        help='Disable majority voting')
    parser.add_argument('--plot', action='store_true',
                        help='Generate UMAP visualization plots')
    parser.add_argument('--plot-dir', default=None,
                        help='Directory for plot output')
    
    args = parser.parse_args()
    
    annotate_cells(
        input_path=args.input,
        output_path=args.output,
        model_name=args.model,
        majority_voting=not args.no_majority_voting,
        plot_results=args.plot,
        plot_dir=args.plot_dir
    )


if __name__ == '__main__':
    main()
